import SwiftUI
import AVFoundation
import Speech
import Foundation
import Combine

/// Handles speech recognition using both Apple Speech Framework and WhisperX
class SpeechRecognizer: ObservableObject {
    @Published var recognizedText = ""
    @Published var isRecording = false
    @Published var isAuthorized = false
    @Published var isProcessing = false
    @Published var error: SpeechError?
    
    // Apple Speech Recognition
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    // Audio recording
    private let audioEngine = AVAudioEngine()
    private var audioFile: AVAudioFile?
    private var temporaryAudioURL: URL?
    
    // WhisperX integration
    private let whisperXService = WhisperXService()
    
    init() {
        Task {
            await requestPermissions()
            setupAudioSession()
            checkWhisperXSetup()
        }
    }
    
    // MARK: - Permissions
    
    @MainActor
    private func requestPermissions() async {
        // Request microphone permission
        await withCheckedContinuation { continuation in
            #if os(iOS)
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                Task { @MainActor in
                    self?.isAuthorized = granted
                    print("Microphone permission: \(granted ? "granted" : "denied")")
                    continuation.resume()
                }
            }
            #else
            // On macOS, microphone permission is handled by the system automatically
            Task { @MainActor in
                self.isAuthorized = true
                print("Microphone permission: granted (macOS)")
                continuation.resume()
            }
            #endif
        }
        
        // Request speech recognition permission
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
                Task { @MainActor in
                    switch authStatus {
                    case .authorized:
                        print("Speech recognition authorized")
                    case .denied, .restricted, .notDetermined:
                        print("Speech recognition not authorized: \(authStatus)")
                        self?.error = .authorizationFailed
                    @unknown default:
                        print("Unknown speech recognition authorization status")
                    }
                    continuation.resume()
                }
            }
        }
    }
    
    private func setupAudioSession() {
        #if os(iOS)
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to setup audio session: \(error)")
            self.error = .audioSessionError(error)
        }
        #else
        // On macOS, audio session setup is not needed
        print("Audio session setup not required on macOS")
        #endif
    }
    
    // MARK: - Recording Control
    
    func startRecording() {
        guard isAuthorized else {
            print("Speech recognition not authorized")
            error = .authorizationFailed
            return
        }
        
        // Stop any existing recording
        stopRecording()
        
        // Clear previous results
        recognizedText = ""
        error = nil
        
        do {
            try startAppleSpeechRecognition()
            isRecording = true
            print("Recording started")
        } catch {
            print("Failed to start recording: \(error)")
            self.error = .recordingError(error)
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        
        isRecording = false
        print("Recording stopped")
    }
    
    // MARK: - Apple Speech Recognition
    
    private func startAppleSpeechRecognition() throws {
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            throw SpeechError.recognitionRequestFailed
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // If iOS 13+, prefer on-device recognition when available
        if #available(iOS 13, macOS 10.15, *) {
            recognitionRequest.requiresOnDeviceRecognition = false
        }
        
        let inputNode = audioEngine.inputNode
        
        // Create recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.handleRecognitionResult(result: result, error: error)
            }
        }
        
        // Configure audio input
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        // Start audio engine
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    private func handleRecognitionResult(result: SFSpeechRecognitionResult?, error: Error?) {
        if let result = result {
            recognizedText = result.bestTranscription.formattedString
            
            // If the result is final, stop recording
            if result.isFinal {
                stopRecording()
            }
        }
        
        if let error = error {
            print("Recognition error: \(error.localizedDescription)")
            self.error = .recognitionError(error)
            stopRecording()
        }
    }
    
    // MARK: - WhisperX Integration
    
    private func checkWhisperXSetup() {
        whisperXService.checkAvailability { available in
            if available {
                print("WhisperX service is available")
            } else {
                print("WhisperX service not available - using Apple Speech Recognition only")
            }
        }
    }
    
    /// Use WhisperX for transcription (alternative to Apple's service)
    func transcribeWithWhisperX(audioURL: URL) async {
        isProcessing = true
        
        do {
            let result = try await whisperXService.transcribe(audioURL: audioURL)
            
            DispatchQueue.main.async {
                self.recognizedText = result
                self.isProcessing = false
            }
        } catch {
            DispatchQueue.main.async {
                self.error = .whisperXError(error)
                self.isProcessing = false
            }
        }
    }
}

// MARK: - Error Types

enum SpeechError: LocalizedError {
    case authorizationFailed
    case audioSessionError(Error)
    case recognitionRequestFailed
    case recordingError(Error)
    case recognitionError(Error)
    case whisperXError(Error)
    
    var errorDescription: String? {
        switch self {
        case .authorizationFailed:
            return "Speech recognition not authorized. Please enable in Settings."
        case .audioSessionError(let error):
            return "Audio session error: \(error.localizedDescription)"
        case .recognitionRequestFailed:
            return "Failed to create speech recognition request"
        case .recordingError(let error):
            return "Recording error: \(error.localizedDescription)"
        case .recognitionError(let error):
            return "Recognition error: \(error.localizedDescription)"
        case .whisperXError(let error):
            return "WhisperX error: \(error.localizedDescription)"
        }
    }
}

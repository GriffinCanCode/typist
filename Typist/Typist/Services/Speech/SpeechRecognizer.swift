import SwiftUI
import AVFoundation
import Speech
import Foundation
import Combine

/// Handles speech recognition using both Apple Speech Framework and WhisperX
public class SpeechRecognizer: ObservableObject {
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
    
    // Timeout management
    private var recordingTimer: Timer?
    private let maxRecordingDuration: TimeInterval = 30.0 // 30 seconds max
    private let noSpeechTimeout: TimeInterval = 8.0 // 8 seconds of no speech before stopping
    private var lastSpeechTime: Date = Date()
    
    // WhisperX integration (disabled for now)
    // private let whisperXService = WhisperXService()
    
    public init() {
        Task {
            await requestPermissions()
            setupAudioSession()
            // checkWhisperXSetup()
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
    
    public func startRecording() {
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
        lastSpeechTime = Date()
        
        do {
            try startAppleSpeechRecognition()
            isRecording = true
            startRecordingTimer()
            print("Recording started")
        } catch {
            print("Failed to start recording: \(error)")
            self.error = .recordingError(error)
        }
    }
    
    public func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Clean up timer
        recordingTimer?.invalidate()
        recordingTimer = nil
        
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
        
        // Add timeout to prevent premature stopping
        recognitionRequest.taskHint = .dictation
        
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
            let newText = result.bestTranscription.formattedString
            recognizedText = newText
            
            // Update last speech time if we have meaningful text
            if !newText.trimmingCharacters(in: .whitespaces).isEmpty {
                lastSpeechTime = Date()
            }
            
            // If the result is final and we have meaningful text, stop recording
            if result.isFinal && !newText.trimmingCharacters(in: .whitespaces).isEmpty {
                print("Final recognition result: '\(newText)'")
                stopRecording()
            }
        }
        
        if let error = error {
            let errorDescription = error.localizedDescription
            print("Recognition error: \(errorDescription)")
            
            // Ignore "no speech detected" errors - let the timer handle timeouts instead
            if errorDescription.contains("No speech detected") {
                print("Ignoring 'no speech detected' - continuing to listen")
                return // Don't stop recording, just continue listening
            }
            
            // Only treat certain errors as critical
            self.error = .recognitionError(error)
            stopRecording()
        }
    }
    
    // MARK: - Timer Management
    
    private func startRecordingTimer() {
        recordingTimer?.invalidate() // Clear any existing timer
        
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkRecordingTimeout()
            }
        }
    }
    
    private func checkRecordingTimeout() {
        guard isRecording else {
            recordingTimer?.invalidate()
            recordingTimer = nil
            return
        }
        
        let now = Date()
        let timeSinceStart = now.timeIntervalSince(lastSpeechTime)
        
        // Stop if we've been recording for too long overall
        if timeSinceStart > maxRecordingDuration {
            print("Recording timeout: Maximum duration reached (\(maxRecordingDuration)s)")
            stopRecording()
            return
        }
        
        // Stop if no speech detected for too long (but only if we haven't detected any speech at all)
        if recognizedText.trimmingCharacters(in: .whitespaces).isEmpty && timeSinceStart > noSpeechTimeout {
            print("Recording timeout: No speech detected for \(noSpeechTimeout)s")
            stopRecording()
        }
    }
    
    // MARK: - WhisperX Integration
    
    /*
    private func checkWhisperXSetup() {
        whisperXService.checkAvailability { available in
            if available {
                print("WhisperX service is available")
            } else {
                print("WhisperX service not available - using Apple Speech Recognition only")
            }
        }
    }
    */
    
    /*
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
    */
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

import Foundation
import AppKit

/// Global constants used throughout the Typist application
enum Constants {
    
    // MARK: - Window Identifiers
    enum WindowID {
        static let main = "MainWindow"
        static let floating = "floating-window"
    }
    
    // MARK: - Audio Settings
    enum Audio {
        static let sampleRate: Double = 16000
        static let bufferSize: AVAudioFrameCount = 1024
        static let recordingFormat = "wav"
        static let maxRecordingDuration: TimeInterval = 300 // 5 minutes
    }
    
    // MARK: - UI Configuration
    enum UI {
        static let floatingWindowSize = CGSize(width: 200, height: 60)
        static let mainWindowSize = CGSize(width: 320, height: 250)
        static let cornerRadius: CGFloat = 25
        static let shadowRadius: CGFloat = 8
        static let animationDuration: TimeInterval = 0.3
        
        enum Colors {
            static let primaryBlue = NSColor.systemBlue
            static let recordingRed = NSColor.systemRed
            static let glassBorder = NSColor.white.withAlphaComponent(0.3)
            static let glassBackground = NSColor.white.withAlphaComponent(0.15)
        }
    }
    
    // MARK: - Timing
    enum Timing {
        static let autoCloseDelay: TimeInterval = 1.5
        static let clipboardRestoreDelay: TimeInterval = 0.5
        static let keyPressDelay: useconds_t = 10000 // 10ms
        static let recordingAnimationDuration: TimeInterval = 0.6
    }
    
    // MARK: - File Paths
    enum FilePaths {
        static let tempDirectory = NSTemporaryDirectory()
        static let audioFilePrefix = "typist_audio"
        static let logFileName = "typist.log"
        
        static var tempAudioURL: URL {
            let filename = "\(audioFilePrefix)_\(Date().timeIntervalSince1970).wav"
            return URL(fileURLWithPath: tempDirectory).appendingPathComponent(filename)
        }
        
        static var logFileURL: URL {
            return URL(fileURLWithPath: tempDirectory).appendingPathComponent(logFileName)
        }
    }
    
    // MARK: - WhisperX Configuration
    enum WhisperX {
        static let defaultModelSize = "base"
        static let supportedLanguages = ["en", "es", "fr", "de", "it", "pt", "ru", "ja", "ko", "zh"]
        static let defaultLanguage = "en"
        static let maxRetries = 3
        static let timeoutInterval: TimeInterval = 60.0
    }
    
    // MARK: - System
    enum System {
        static let appBundleIdentifier = "com.typist.app"
        static let pythonExecutable = "/usr/bin/python3"
        static let spaceKeyCode: UInt16 = 49
        
        enum Entitlements {
            static let microphone = "NSMicrophoneUsageDescription"
            static let speechRecognition = "NSSpeechRecognitionUsageDescription"
            static let accessibility = "NSAppleEventsUsageDescription"
        }
    }
    
    // MARK: - Error Messages
    enum ErrorMessages {
        static let microphonePermissionDenied = "Microphone access is required for voice transcription. Please enable it in System Preferences > Security & Privacy > Privacy > Microphone."
        static let speechRecognitionDenied = "Speech recognition permission is required. Please enable it in System Preferences > Security & Privacy > Privacy > Speech Recognition."
        static let whisperXNotAvailable = "WhisperX service is not available. Please run the setup script in Services/Python/setup.py"
        static let recordingFailed = "Failed to start audio recording. Please check your microphone connection."
        static let transcriptionFailed = "Transcription failed. Please try again or check your internet connection."
        static let audioFileNotFound = "Audio file not found or could not be created."
    }
    
    // MARK: - Notification Names
    enum Notifications {
        static let windowWillClose = NSNotification.Name("TypistWindowWillClose")
        static let transcriptionCompleted = NSNotification.Name("TypistTranscriptionCompleted")
        static let recordingStarted = NSNotification.Name("TypistRecordingStarted")
        static let recordingStopped = NSNotification.Name("TypistRecordingStopped")
        static let errorOccurred = NSNotification.Name("TypistErrorOccurred")
    }
    
    // MARK: - User Defaults Keys
    enum UserDefaultsKeys {
        static let selectedModelSize = "SelectedWhisperXModelSize"
        static let preferredLanguage = "PreferredTranscriptionLanguage"
        static let autoCloseEnabled = "AutoCloseFloatingWindow"
        static let hotkeyEnabled = "GlobalHotkeyEnabled"
        static let lastUsedVersion = "LastUsedAppVersion"
    }
}

import SwiftUI
import AppKit

struct FloatingWindowView: View {
    @EnvironmentObject var speechRecognizer: SpeechRecognizer
    @State private var transcribedText = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack(spacing: 12) {
            microphoneButton
            statusIndicator
            closeButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .onReceive(speechRecognizer.$recognizedText) { text in
            handleRecognizedText(text)
        }
        .onAppear {
            setupWindowProperties()
        }
    }
    
    // MARK: - View Components
    
    private var microphoneButton: some View {
        Button(action: toggleRecording) {
            Image(systemName: speechRecognizer.isRecording ? "mic.fill" : "mic")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(speechRecognizer.isRecording ? .red : .primary)
        }
        .buttonStyle(NonFocusStealingButtonStyle())
        .disabled(speechRecognizer.isProcessing)
        .accessibilityLabel(speechRecognizer.isRecording ? "Stop recording" : "Start recording")
    }
    
    @ViewBuilder
    private var statusIndicator: some View {
        if speechRecognizer.isRecording {
            Text("Listening...")
                .font(.caption)
                .foregroundColor(.secondary)
        } else if speechRecognizer.isProcessing {
            HStack(spacing: 4) {
                Text("Processing...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ProgressView()
                    .scaleEffect(0.6)
            }
        }
    }
    
    private var closeButton: some View {
        Button(action: closeWindow) {
            Image(systemName: "xmark")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .buttonStyle(NonFocusStealingButtonStyle())
        .accessibilityLabel("Close window")
    }
    
    // MARK: - Actions
    
    private func toggleRecording() {
        // Prevent multiple rapid taps
        guard !speechRecognizer.isProcessing else { 
            print("🔥 Ignoring tap - already processing")
            return 
        }
        
        print("🔥 Toggle recording - currently recording: \(speechRecognizer.isRecording)")
        
        if speechRecognizer.isRecording {
            speechRecognizer.stopRecording()
        } else {
            speechRecognizer.startRecording()
        }
    }
    
    private func closeWindow() {
        print("🔥 FloatingWindowView: Close button tapped")
        
        // Stop recording immediately
        if speechRecognizer.isRecording {
            print("🔥 Stopping recording before close")
            speechRecognizer.stopRecording()
        }
        
        // Close window immediately
        print("🔥 Dismissing window")
        dismiss()
    }
    
    private func setupWindowProperties() {
        print("🔥 FloatingWindowView.setupWindowProperties() called")
        
        // Delay slightly to ensure window is fully loaded
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            print("🔥 Setting up window properties")
            WindowManager.shared.setupFloatingWindowProperties()
        }
    }
    
    private func handleRecognizedText(_ text: String) {
        guard !text.isEmpty else { 
            print("🔥 FloatingWindowView: Received empty text, ignoring")
            return 
        }
        
        print("🔥 FloatingWindowView: Received text: '\(text)'")
        transcribedText = text
        
        // Shorter delay since we're not stealing focus anymore
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            print("🔥 FloatingWindowView: Inserting text: '\(text)'")
            ClipboardManager.shared.insertTextIntoActiveField(text)
            
            // Auto-close after successful transcription with shorter delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                print("🔥 FloatingWindowView: Auto-closing after successful transcription")
                self.dismiss()
            }
        }
    }
}

// MARK: - Custom Button Style

struct NonFocusStealingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .contentShape(Rectangle()) // Ensures the entire button area is tappable
    }
}

#Preview {
    FloatingWindowView()
        .environmentObject(SpeechRecognizer())
}

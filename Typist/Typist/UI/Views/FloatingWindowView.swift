import SwiftUI
import AppKit

struct FloatingWindowView: View {
    @EnvironmentObject var speechRecognizer: SpeechRecognizer
    @State private var isRecording = false
    @State private var recordingAnimation = false
    @State private var transcribedText = ""
    @State private var showingText = false
    
    var body: some View {
        HStack(spacing: 12) {
            microphoneButton
            statusIndicator
            closeButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(GlassmorphismBackground())
        .cornerRadius(25)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
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
            Image(systemName: isRecording ? "mic.fill" : "mic")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(isRecording ? .red : .primary)
                .scaleEffect(recordingAnimation ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true),
                          value: recordingAnimation)
        }
        .buttonStyle(GlassButtonStyle())
        .accessibilityLabel(isRecording ? "Stop recording" : "Start recording")
    }
    
    @ViewBuilder
    private var statusIndicator: some View {
        if isRecording {
            HStack(spacing: 4) {
                Text("Listening...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Animated dots
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .frame(width: 4, height: 4)
                            .foregroundColor(.secondary)
                            .scaleEffect(recordingAnimation ? 1.0 : 0.5)
                            .animation(.easeInOut(duration: 0.4)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                                      value: recordingAnimation)
                    }
                }
            }
            .transition(.opacity.combined(with: .scale))
        }
    }
    
    private var closeButton: some View {
        Button(action: closeWindow) {
            Image(systemName: "xmark")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Close window")
    }
    
    // MARK: - Actions
    
    private func toggleRecording() {
        if isRecording {
            speechRecognizer.stopRecording()
            isRecording = false
            recordingAnimation = false
        } else {
            speechRecognizer.startRecording()
            isRecording = true
            recordingAnimation = true
        }
    }
    
    private func closeWindow() {
        if isRecording {
            speechRecognizer.stopRecording()
        }
        
        WindowManager.shared.hideFloatingWindow()
    }
    
    private func setupWindowProperties() {
        DispatchQueue.main.async {
            WindowManager.shared.setupFloatingWindowProperties()
        }
    }
    
    private func handleRecognizedText(_ text: String) {
        guard !text.isEmpty else { return }
        
        transcribedText = text
        showingText = true
        ClipboardManager.shared.insertTextIntoActiveField(text)
        
        // Auto-close after successful transcription
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            closeWindow()
        }
    }
}

#Preview {
    FloatingWindowView()
        .environmentObject(SpeechRecognizer())
}

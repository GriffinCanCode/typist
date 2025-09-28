import SwiftUI

struct ContentView: View {
    @EnvironmentObject var hotkeyManager: HotkeyManager
    @EnvironmentObject var speechRecognizer: SpeechRecognizer
    @State private var isFloatingWindowVisible = false
    
    var body: some View {
        VStack(spacing: 20) {
            headerSection
            
            Divider()
            
            instructionsSection
            
            testingSection
        }
        .padding(24)
        .frame(maxWidth: 320, maxHeight: 250)
        .onReceive(hotkeyManager.$shouldShowWindow) { shouldShow in
            if shouldShow {
                toggleFloatingWindow()
                hotkeyManager.shouldShowWindow = false
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "mic.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
                .symbolEffect(.pulse, options: .repeating)
            
            VStack(spacing: 4) {
                Text("Typist")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Voice-to-Text Tool")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var instructionsSection: some View {
        VStack(spacing: 12) {
            Text("How to use:")
                .font(.headline)
                .fontWeight(.medium)
            
            VStack(spacing: 6) {
                InstructionRow(number: "1", text: "Make sure this app is active")
                InstructionRow(number: "2", text: "Press \(hotkeyManager.displayString)")
                InstructionRow(number: "3", text: "Click microphone and speak")
            }
        }
    }
    
    private var testingSection: some View {
        Button("Show Popup (for testing)") {
            toggleFloatingWindow()
        }
        .keyboardShortcut("t", modifiers: [.command, .shift])
        .buttonStyle(.borderedProminent)
    }
    
    // MARK: - Actions
    
    private func toggleFloatingWindow() {
        WindowManager.shared.toggleFloatingWindow()
    }
}

// MARK: - Supporting Views

struct InstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Text(number)
                .font(.caption)
                .fontWeight(.semibold)
                .frame(width: 20, height: 20)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .clipShape(Circle())
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(HotkeyManager())
        .environmentObject(SpeechRecognizer())
}

import SwiftUI
import Carbon
import ApplicationServices

struct ContentView: View {
    @EnvironmentObject var hotkeyManager: HotkeyManager
    @EnvironmentObject var speechRecognizer: SpeechRecognizer
    @State private var isFloatingWindowVisible = false
    @Environment(\.openWindow) private var openWindow
    
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
            print("🔥 ContentView received shouldShowWindow = \(shouldShow)")
            if shouldShow {
                print("🔥 ContentView calling toggleFloatingWindow()")
                toggleFloatingWindow()
                // Reset the flag after a brief delay to prevent immediate closing
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    hotkeyManager.shouldShowWindow = false
                }
            }
        }
        .sheet(isPresented: $hotkeyManager.shouldShowAccessibilityModal) {
            AccessibilityPermissionModal()
                .environmentObject(hotkeyManager)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            // Check permissions when app becomes active (e.g., user returns from System Settings)
            hotkeyManager.checkAccessibilityPermissions()
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
                if AXIsProcessTrusted() {
                    InstructionRow(number: "1", text: "Press \(hotkeyManager.displayString) from anywhere")
                } else {
                    InstructionRow(number: "1", text: "Make sure this app is active")
                }
                InstructionRow(number: "2", text: "Press \(hotkeyManager.displayString)")
                InstructionRow(number: "3", text: "Click microphone and speak")
            }
        }
    }
    
    private var testingSection: some View {
        Button("Show Popup (for testing)") {
            print("🔥 Test button pressed")
            openWindow(id: "floating-window")
        }
        .keyboardShortcut("t", modifiers: [.command, .shift])
        .buttonStyle(.borderedProminent)
    }
    
    // MARK: - Actions
    
    private func toggleFloatingWindow() {
        print("🔥 ContentView.toggleFloatingWindow() called")
        // Use SwiftUI's proper window management instead of manual window finding
        openWindow(id: "floating-window")
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

// MARK: - Accessibility Permission Modal

struct AccessibilityPermissionModal: View {
    @EnvironmentObject var hotkeyManager: HotkeyManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
                
                VStack(spacing: 4) {
                    Text("Enable Global Hotkeys")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Get system-wide access")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Explanation
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Why enable this?")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text("Currently, hotkeys only work when Typist is the active app. With accessibility permissions, you can use ⌘⇧Space from anywhere on your Mac.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("How to enable:")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text("1.")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(width: 20, height: 20)
                                .background(Color.orange.opacity(0.1))
                                .foregroundColor(.orange)
                                .clipShape(Circle())
                            
                            Text("Click 'Open System Settings' below")
                                .font(.body)
                        }
                        
                        HStack(spacing: 8) {
                            Text("2.")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(width: 20, height: 20)
                                .background(Color.orange.opacity(0.1))
                                .foregroundColor(.orange)
                                .clipShape(Circle())
                            
                            Text("Find 'Typist' in the list and enable it")
                                .font(.body)
                        }
                        
                        HStack(spacing: 8) {
                            Text("3.")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(width: 20, height: 20)
                                .background(Color.orange.opacity(0.1))
                                .foregroundColor(.orange)
                                .clipShape(Circle())
                            
                            Text("Come back and enjoy global hotkeys!")
                                .font(.body)
                        }
                    }
                }
            }
            
            // Buttons
            VStack(spacing: 12) {
                Button(action: {
                    hotkeyManager.openAccessibilitySettings()
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "gear")
                        Text("Open System Settings")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button("Maybe Later") {
                    dismiss()
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(24)
        .frame(maxWidth: 480)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    ContentView()
        .environmentObject(HotkeyManager())
        .environmentObject(SpeechRecognizer())
}

#Preview("Accessibility Modal") {
    AccessibilityPermissionModal()
        .environmentObject(HotkeyManager())
}

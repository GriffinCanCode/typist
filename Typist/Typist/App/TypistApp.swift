import SwiftUI
import AppKit

// Import all our custom modules
import Foundation

@main
struct TypistApp: App {
    @StateObject private var hotkeyManager = HotkeyManager()
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        // Main window (hidden by default)  
        WindowGroup {
            ContentView()
                .environmentObject(hotkeyManager)
                .environmentObject(speechRecognizer)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 300, height: 200)
        .commands {
            // Remove default menu items we don't need
            CommandGroup(replacing: .newItem) {}
            CommandGroup(replacing: .undoRedo) {}
            CommandGroup(replacing: .pasteboard) {}
        }
        
        // Floating window for the microphone popup
        Window("Typist Popup", id: "floating-window") {
            FloatingWindowView()
                .environmentObject(hotkeyManager)
                .environmentObject(speechRecognizer)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 200, height: 60)
    }
}

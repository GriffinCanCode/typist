import SwiftUI
import AppKit

/// Manages global and local hotkey registration and handling
class HotkeyManager: ObservableObject {
    @Published var shouldShowWindow = false
    
    /// The display string for the current hotkey combination
    var displayString: String {
        return "⌘⇧Space (when app is active)"
    }
    
    init() {
        registerLocalHotkey()
        setupGlobalHotkeysIfAvailable()
    }
    
    // MARK: - Local Hotkeys
    
    /// Register local hotkeys that only work when the app is focused
    /// This doesn't require special entitlements
    private func registerLocalHotkey() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            return self?.handleKeyEvent(event) ?? event
        }
        
        print("Successfully registered local hotkey: ⌘⇧Space")
        print("Note: App must be active for hotkey to work")
    }
    
    /// Handle incoming key events for local hotkeys
    /// - Parameter event: The keyboard event
    /// - Returns: The event if not handled, nil if consumed
    private func handleKeyEvent(_ event: NSEvent) -> NSEvent? {
        // Check for Cmd+Shift+Space combination
        if event.modifierFlags.contains([.command, .shift]) && 
           event.keyCode == 49 { // Space key
            DispatchQueue.main.async {
                self.shouldShowWindow = true
            }
            return nil // Consume the event
        }
        
        return event // Pass through unhandled events
    }
    
    // MARK: - Global Hotkeys (Future Enhancement)
    
    /// Setup global hotkeys if the app has the necessary permissions
    /// This would require entitlements and user approval
    private func setupGlobalHotkeysIfAvailable() {
        // Check if we have accessibility permissions for global hotkeys
        if hasGlobalHotkeyPermissions() {
            registerGlobalHotkeys()
        } else {
            print("Global hotkeys not available - using local hotkeys only")
            print("To enable global hotkeys, grant accessibility permissions in System Preferences")
        }
    }
    
    /// Register global hotkeys that work system-wide
    private func registerGlobalHotkeys() {
        // TODO: Implement global hotkey registration
        // This would use Carbon's RegisterEventHotKey or modern alternatives
        print("Global hotkeys not yet implemented - using local hotkeys")
    }
    
    /// Check if the app has permissions for global hotkey registration
    /// - Returns: True if permissions are available
    private func hasGlobalHotkeyPermissions() -> Bool {
        // Check for accessibility permissions
        return AXIsProcessTrusted()
    }
    
    // MARK: - Hotkey Configuration
    
    /// Available hotkey combinations
    enum HotkeyConfig {
        case cmdShiftSpace
        case cmdSpace
        case optionSpace
        
        var keyCode: UInt16 {
            switch self {
            case .cmdShiftSpace, .cmdSpace, .optionSpace:
                return 49 // Space key
            }
        }
        
        var modifiers: NSEvent.ModifierFlags {
            switch self {
            case .cmdShiftSpace:
                return [.command, .shift]
            case .cmdSpace:
                return [.command]
            case .optionSpace:
                return [.option]
            }
        }
        
        var displayString: String {
            switch self {
            case .cmdShiftSpace:
                return "⌘⇧Space"
            case .cmdSpace:
                return "⌘Space"
            case .optionSpace:
                return "⌥Space"
            }
        }
    }
    
    // MARK: - Public Interface
    
    /// Manually trigger the window show action (for testing)
    func triggerShowWindow() {
        DispatchQueue.main.async {
            self.shouldShowWindow = true
        }
    }
    
    /// Reset the window show flag
    func resetShowWindow() {
        shouldShowWindow = false
    }
}

import SwiftUI
import AppKit
import Combine
import Carbon

/// Manages global and local hotkey registration and handling
public class HotkeyManager: ObservableObject {
    @Published var shouldShowWindow = false
    @Published var shouldShowAccessibilityModal = false
    
    // Global hotkey tracking
    private var globalHotkeyRef: EventHotKeyRef?
    static let hotkeyID = EventHotKeyID(signature: OSType(0x54595053), id: 1) // 'TYPS' signature
    
    /// The display string for the current hotkey combination
    public var displayString: String {
        return hasGlobalHotkeyPermissions() ? "⌘⇧Space" : "⌘⇧Space (when app is active)"
    }
    
    public init() {
        registerLocalHotkey()
        setupGlobalHotkeysIfAvailable()
    }
    
    deinit {
        unregisterGlobalHotkeys()
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
            print("🔥 LOCAL HOTKEY TRIGGERED: Cmd+Shift+Space detected!")
            DispatchQueue.main.async {
                print("🔥 Setting shouldShowWindow = true")
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
            
            // Request accessibility permissions - this will trigger the system dialog
            // if permissions haven't been granted yet
            requestAccessibilityPermissions()
            
            // Show our custom modal after a brief delay to let the app fully load
            // This provides additional context and guidance to the user
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.shouldShowAccessibilityModal = true
            }
        }
    }
    
    /// Register global hotkeys that work system-wide
    private func registerGlobalHotkeys() {
        // First unregister any existing global hotkey
        unregisterGlobalHotkeys()
        
        // Setup event handler
        var eventHandler: EventHandlerRef?
        let eventSpecs = [EventTypeSpec(eventClass: OSType(kEventClassKeyboard), 
                                       eventKind: OSType(kEventHotKeyPressed))]
        
        let status = InstallEventHandler(
            GetEventDispatcherTarget(),
            globalHotkeyHandler,
            1,
            eventSpecs,
            UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
            &eventHandler
        )
        
        guard status == noErr else {
            print("Failed to install global hotkey event handler: \(status)")
            return
        }
        
        // Register the global hotkey (Cmd+Shift+Space)
        let registerStatus = RegisterEventHotKey(
            UInt32(kVK_Space),      // Space key
            UInt32(cmdKey | shiftKey), // Cmd+Shift modifiers
            HotkeyManager.hotkeyID,
            GetEventDispatcherTarget(),
            0,
            &globalHotkeyRef
        )
        
        if registerStatus == noErr {
            print("Successfully registered global hotkey: ⌘⇧Space")
        } else {
            print("Failed to register global hotkey: \(registerStatus)")
        }
    }
    
    /// Unregister global hotkeys
    private func unregisterGlobalHotkeys() {
        if let hotkeyRef = globalHotkeyRef {
            UnregisterEventHotKey(hotkeyRef)
            globalHotkeyRef = nil
        }
    }
    
    /// Check if the app has permissions for global hotkey registration
    /// - Returns: True if permissions are available
    private func hasGlobalHotkeyPermissions() -> Bool {
        // Check for accessibility permissions
        return AXIsProcessTrusted()
    }
    
    /// Request accessibility permissions from the user
    /// This will show the system dialog to grant permissions
    private func requestAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let trusted = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if trusted {
            print("Accessibility permissions already granted")
        } else {
            print("Requesting accessibility permissions from user")
        }
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
    
    /// Dismiss the accessibility modal
    func dismissAccessibilityModal() {
        shouldShowAccessibilityModal = false
    }
    
    /// Check permissions and update modal state
    public func checkAccessibilityPermissions() {
        let hasPermissions = hasGlobalHotkeyPermissions()
        
        if hasPermissions && shouldShowAccessibilityModal {
            // Permissions were just granted - dismiss modal and setup global hotkeys
            shouldShowAccessibilityModal = false
            registerGlobalHotkeys()
            print("Accessibility permissions granted - global hotkeys enabled!")
        } else if !hasPermissions && !shouldShowAccessibilityModal {
            // Only show modal if it's not already showing
            shouldShowAccessibilityModal = true
        }
    }
    
    /// Open System Preferences to the Accessibility section
    public func openAccessibilitySettings() {
        // First request accessibility permissions to ensure the app appears in the list
        requestAccessibilityPermissions()
        
        // Then open System Settings to the Accessibility section
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
    
    /// Manually request accessibility permissions (public interface)
    /// This can be called from the UI to trigger the permission request
    func requestAccessibilityPermissionsManually() {
        requestAccessibilityPermissions()
    }
}

// MARK: - Global Hotkey Event Handler

/// Global hotkey event handler function
/// This C function is called when a global hotkey is pressed
private func globalHotkeyHandler(
    nextHandler: EventHandlerCallRef?,
    theEvent: EventRef?,
    userData: UnsafeMutableRawPointer?
) -> OSStatus {
    
    guard let userData = userData else { return OSStatus(eventNotHandledErr) }
    
    let hotkeyManager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
    
    // Extract hotkey ID from the event
    var hotkeyID = EventHotKeyID()
    let status = GetEventParameter(
        theEvent,
        EventParamName(kEventParamDirectObject),
        EventParamType(typeEventHotKeyID),
        nil,
        MemoryLayout<EventHotKeyID>.size,
        nil,
        &hotkeyID
    )
    
    // Check if this is our hotkey
    if status == noErr && hotkeyID.id == HotkeyManager.hotkeyID.id {
        print("🔥 GLOBAL HOTKEY TRIGGERED: Cmd+Shift+Space detected!")
        DispatchQueue.main.async {
            print("🔥 Setting shouldShowWindow = true via global hotkey")
            hotkeyManager.shouldShowWindow = true
        }
        return noErr
    }
    
    return OSStatus(eventNotHandledErr)
}

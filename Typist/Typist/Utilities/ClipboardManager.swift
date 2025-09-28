import Foundation
import AppKit
import CoreGraphics

/// Manages clipboard operations and text insertion into the active application
class ClipboardManager {
    static let shared = ClipboardManager()
    
    private init() {}
    
    // MARK: - Text Insertion
    
    /// Insert text into the currently active text field using clipboard and paste simulation
    /// - Parameter text: The text to insert
    func insertTextIntoActiveField(_ text: String) {
        guard !text.isEmpty else {
            print("Warning: Attempted to insert empty text")
            return
        }
        
        // Store original clipboard content to restore later
        let originalClipboard = getClipboardContent()
        
        // Set new text to clipboard
        setClipboardContent(text)
        
        // Wait a brief moment for clipboard to update
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.simulatePasteCommand()
            
            // Restore original clipboard content after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let originalContent = originalClipboard {
                    self.setClipboardContent(originalContent)
                }
            }
        }
        
        print("Text inserted via clipboard: \(text)")
    }
    
    /// Insert text directly using CGEvents (alternative method)
    /// - Parameter text: The text to insert
    func insertTextDirectly(_ text: String) {
        guard !text.isEmpty else { return }
        
        // Create event source
        guard let eventSource = CGEventSource(stateID: .hidSystemState) else {
            print("Error: Could not create event source")
            return
        }
        
        // Type each character
        for character in text.unicodeScalars {
            let keyCode = mapUnicodeToKeyCode(character)
            
            // Key down event
            if let keyDownEvent = CGEvent(keyboardEventSource: eventSource, 
                                        virtualKey: keyCode, 
                                        keyDown: true) {
                keyDownEvent.post(tap: .cghidEventTap)
            }
            
            // Key up event
            if let keyUpEvent = CGEvent(keyboardEventSource: eventSource, 
                                      virtualKey: keyCode, 
                                      keyDown: false) {
                keyUpEvent.post(tap: .cghidEventTap)
            }
            
            // Small delay between characters for reliability
            usleep(10000) // 10ms
        }
    }
    
    // MARK: - Clipboard Operations
    
    /// Get the current clipboard content
    /// - Returns: The clipboard string content, or nil if empty
    private func getClipboardContent() -> String? {
        let pasteboard = NSPasteboard.general
        return pasteboard.string(forType: .string)
    }
    
    /// Set content to the clipboard
    /// - Parameter content: The string content to set
    private func setClipboardContent(_ content: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(content, forType: .string)
    }
    
    // MARK: - Paste Simulation
    
    /// Simulate the Cmd+V paste command
    private func simulatePasteCommand() {
        guard let eventSource = CGEventSource(stateID: .hidSystemState) else {
            print("Error: Could not create event source for paste command")
            return
        }
        
        // Key down for Cmd+V
        if let cmdVDown = CGEvent(keyboardEventSource: eventSource, 
                                virtualKey: 0x09, // V key
                                keyDown: true) {
            cmdVDown.flags = .maskCommand
            cmdVDown.post(tap: .cghidEventTap)
        }
        
        // Small delay
        usleep(10000) // 10ms
        
        // Key up for Cmd+V
        if let cmdVUp = CGEvent(keyboardEventSource: eventSource, 
                              virtualKey: 0x09, // V key
                              keyDown: false) {
            cmdVUp.flags = .maskCommand
            cmdVUp.post(tap: .cghidEventTap)
        }
    }
    
    // MARK: - Character Mapping
    
    /// Map Unicode scalar to virtual key code (simplified mapping)
    /// - Parameter scalar: The Unicode scalar to map
    /// - Returns: The corresponding virtual key code
    private func mapUnicodeToKeyCode(_ scalar: UnicodeScalar) -> CGKeyCode {
        // This is a simplified mapping - in a production app, you'd want a complete mapping
        switch scalar.value {
        case 32: return 0x31 // Space
        case 65...90: return CGKeyCode(scalar.value - 65) // A-Z
        case 97...122: return CGKeyCode(scalar.value - 97) // a-z
        default: return 0x31 // Default to space for unmapped characters
        }
    }
    
    // MARK: - Validation
    
    /// Check if accessibility permissions are granted for direct text insertion
    /// - Returns: True if permissions are granted
    func hasAccessibilityPermissions() -> Bool {
        return AXIsProcessTrustedWithOptions([
            kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true
        ] as CFDictionary)
    }
    
    /// Request accessibility permissions if not already granted
    func requestAccessibilityPermissions() {
        if !hasAccessibilityPermissions() {
            print("Accessibility permissions required for direct text insertion")
            // The system will show a dialog requesting permissions
        }
    }
}

import SwiftUI
import AppKit

/// Manages floating window behavior and positioning
class WindowManager: ObservableObject {
    static let shared = WindowManager()
    
    private init() {}
    
    // MARK: - Window Management
    
    /// Toggle the floating window visibility
    func toggleFloatingWindow() {
        if let window = getFloatingWindow() {
            if window.isVisible {
                hideFloatingWindow()
            } else {
                showFloatingWindow()
            }
        }
    }
    
    /// Show the floating window positioned near the mouse cursor
    func showFloatingWindow() {
        guard let window = getFloatingWindow() else {
            print("Warning: Floating window not found")
            return
        }
        
        positionWindowNearMouse(window)
        window.makeKeyAndOrderFront(nil)
        window.level = .floating
    }
    
    /// Hide the floating window
    func hideFloatingWindow() {
        guard let window = getFloatingWindow() else { return }
        window.orderOut(nil)
    }
    
    /// Setup properties for the floating window to achieve glassmorphism effect
    func setupFloatingWindowProperties() {
        guard let window = getFloatingWindow() else { return }
        
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]
        window.hidesOnDeactivate = false
        
        // Add subtle window shadow
        window.hasShadow = true
    }
    
    // MARK: - Window Positioning
    
    /// Position the window near the current mouse location with smart screen boundary handling
    private func positionWindowNearMouse(_ window: NSWindow) {
        let mouseLocation = NSEvent.mouseLocation
        let windowSize = window.frame.size
        
        // Get screen bounds
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        
        // Calculate desired position (slightly above and left of cursor)
        var newOrigin = CGPoint(
            x: mouseLocation.x - (windowSize.width / 2),
            y: mouseLocation.y + 20 // Position above cursor
        )
        
        // Ensure window stays within screen bounds
        newOrigin = constrainToScreen(origin: newOrigin, 
                                    windowSize: windowSize, 
                                    screenFrame: screenFrame)
        
        window.setFrameOrigin(newOrigin)
    }
    
    /// Constrain window position to stay within screen bounds
    private func constrainToScreen(origin: CGPoint, 
                                 windowSize: CGSize, 
                                 screenFrame: CGRect) -> CGPoint {
        var constrainedOrigin = origin
        
        // Constrain horizontal position
        let minX = screenFrame.minX
        let maxX = screenFrame.maxX - windowSize.width
        constrainedOrigin.x = max(minX, min(maxX, constrainedOrigin.x))
        
        // Constrain vertical position
        let minY = screenFrame.minY
        let maxY = screenFrame.maxY - windowSize.height
        constrainedOrigin.y = max(minY, min(maxY, constrainedOrigin.y))
        
        return constrainedOrigin
    }
    
    // MARK: - Helper Methods
    
    /// Get the floating window instance
    private func getFloatingWindow() -> NSWindow? {
        return NSApp.windows.first { $0.identifier?.rawValue == "floating-window" }
    }
    
    /// Get the main window instance
    private func getMainWindow() -> NSWindow? {
        return NSApp.windows.first { $0.identifier?.rawValue == "MainWindow" }
    }
    
    /// Show the main application window
    func showMainWindow() {
        guard let window = getMainWindow() else { return }
        
        window.makeKeyAndOrderFront(nil)
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    /// Hide the main application window
    func hideMainWindow() {
        guard let window = getMainWindow() else { return }
        
        window.orderOut(nil)
        NSApp.setActivationPolicy(.accessory)
    }
}

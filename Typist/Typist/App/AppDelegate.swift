import Cocoa
import SwiftUI

/// Custom app delegate for managing application lifecycle and window behavior  
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide from dock and cmd+tab switcher for a cleaner UX
        NSApp.setActivationPolicy(.accessory)
        
        // Hide main window on launch - it will only show when explicitly requested
        hideMainWindowOnLaunch()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Keep running even when windows are closed to maintain hotkey functionality
        return false
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // Show main window when app is reopened (e.g., from dock if visible)
        if !flag {
            showMainWindow()
        }
        return true
    }
    
    // MARK: - Private Methods
    
    private func hideMainWindowOnLaunch() {
        NSApp.windows.forEach { window in
            if window.identifier?.rawValue == "MainWindow" {
                window.orderOut(nil)
            }
        }
    }
    
    private func showMainWindow() {
        NSApp.windows.forEach { window in
            if window.identifier?.rawValue == "MainWindow" {
                window.makeKeyAndOrderFront(nil)
            }
        }
    }
}

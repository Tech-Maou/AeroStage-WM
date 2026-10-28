import AppKit

/// AeroStage WM: never quit because a window closed. With the menu bar item hidden, a HUD panel
/// (Secure Input, volume) or the message window can be the app's only window, and SwiftUI quits
/// the app when the last window closes. That left the user without a window manager after
/// typing into any password field.
public final class AeroStageWMAppDelegate: NSObject, NSApplicationDelegate {
    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }
}

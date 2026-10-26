import AppKit
import Common

/// Window ids per non-empty workspace, as of the last completed refresh session
@MainActor private var lastWorkspaceWindowIds: [String: Set<UInt32>] = [:]

/// Broadcasts `workspace-windows-changed` for every workspace whose set of windows changed since the last
/// refresh session: a window appeared, was closed, minimized, unminimized or moved to another workspace.
///
/// Nothing is reported while the screen is locked. The accessibility API then makes all windows look closed
/// (see closedWindowsCache), and the windows come back on unlock. Skipping the locked period keeps the last
/// snapshot, so subscribers see neither the phantom closes nor the restores.
@MainActor
func broadcastWorkspaceWindowsChangedIfNeeded() {
    if isScreenLocked() { return }
    var current: [String: Set<UInt32>] = [:]
    for workspace in Workspace.all {
        let windowIds = workspace.allLeafWindowsRecursive.map(\.windowId).toSet()
        if !windowIds.isEmpty { current[workspace.name] = windowIds }
    }
    let previous = lastWorkspaceWindowIds
    lastWorkspaceWindowIds = current
    for name in Set(previous.keys).union(current.keys).sorted() where previous[name] != current[name] {
        broadcastEvent(.workspaceWindowsChanged(workspace: name, windowIds: (current[name] ?? []).sorted()))
    }
}

private func isScreenLocked() -> Bool {
    let session = CGSessionCopyCurrentDictionary() as? [String: Any]
    return session?["CGSSessionScreenIsLocked"] as? Bool ?? false
}

import AppKit
import Common

/// Windows of a workspace, and which of them float
private struct WorkspaceWindows: Equatable {
    var all: Set<UInt32>
    var floating: Set<UInt32>
}

/// Windows per non-empty workspace, as of the last completed refresh session
@MainActor private var lastWorkspaceWindows: [String: WorkspaceWindows] = [:]

/// Broadcasts `workspace-windows-changed` for every workspace whose windows changed since the last refresh
/// session: a window appeared, was closed, minimized, unminimized, moved to another workspace, or switched
/// between floating and tiling.
///
/// Nothing is reported while the screen is locked. The accessibility API then makes all windows look closed
/// (see closedWindowsCache), and the windows come back on unlock. Skipping the locked period keeps the last
/// snapshot, so subscribers see neither the phantom closes nor the restores.
@MainActor
func broadcastWorkspaceWindowsChangedIfNeeded() {
    if isScreenLocked() { return }
    var current: [String: WorkspaceWindows] = [:]
    for workspace in Workspace.all {
        let windowIds = workspace.allLeafWindowsRecursive.map(\.windowId).toSet()
        if !windowIds.isEmpty {
            current[workspace.name] = WorkspaceWindows(all: windowIds, floating: workspace.floatingWindows.map(\.windowId).toSet())
        }
    }
    let previous = lastWorkspaceWindows
    lastWorkspaceWindows = current
    for name in Set(previous.keys).union(current.keys).sorted() where previous[name] != current[name] {
        broadcastEvent(.workspaceWindowsChanged(workspace: name, windowIds: (current[name]?.all ?? []).sorted()))
    }
}

private func isScreenLocked() -> Bool {
    let session = CGSessionCopyCurrentDictionary() as? [String: Any]
    return session?["CGSSessionScreenIsLocked"] as? Bool ?? false
}

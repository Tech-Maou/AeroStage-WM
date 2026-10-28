import AppBundle
import SwiftUI

// This file is shared between SPM and xcode project

@main
struct AeroSpaceApp: App {
    @StateObject var viewModel = TrayMenuModel.shared
    @StateObject var messageModel = MessageModel.shared
    @Environment(\.openWindow) var openWindow: OpenWindowAction
    @AppStorage("hideMenuBarItem") var hideMenuBarItem = false // AeroStage WM
    @NSApplicationDelegateAdaptor(AeroStageWMAppDelegate.self) var appDelegate // AeroStage WM

    init() {
        initAppBundle()
    }

    var body: some Scene {
        menuBar(viewModel: viewModel, hideMenuBarItem: $hideMenuBarItem)
        getMessageWindow(messageModel: messageModel)
            .onChange(of: messageModel.message) { message in
                if message != nil {
                    openWindow(id: messageWindowId)
                }
            }
    }
}

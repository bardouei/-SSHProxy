//
//  SSHProxy.swift
//  SSHProxy
//
//  Created by baner on 3/22/25.
//

import SwiftUI

@main
struct SSHProxy: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var sshManager = SSHManager()

    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentView = ContentView().environmentObject(sshManager)
        sshManager.statusIconUpdater = self.updateStatusIcon
        popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 350)
        popover.behavior = .transient
        popover.contentViewController = NSViewController()
        popover.contentViewController?.view = NSHostingView(rootView: contentView)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "bolt.horizontal", accessibilityDescription: "SSH Proxy")
            button.action = #selector(togglePopover(_:))
        }
    }

    func updateStatusIcon(isRunning: Bool) {
        if let button = statusItem.button {
            let iconName = isRunning ? "bolt.horizontal.fill" : "bolt.horizontal"
            button.image = NSImage(systemSymbolName: iconName, accessibilityDescription: "SSH Proxy")
        }
    }

    @objc func togglePopover(_ sender: Any?) {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
}

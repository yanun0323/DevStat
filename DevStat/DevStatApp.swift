import Sparkle
//
//  DevStatApp.swift
//  DevStat
//
//  Created by yanun.y on 2024/8/14.
//
import SwiftUI

@main
struct DevStatApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
  @Environment(\.scenePhase) var scenePhase

  var body: some Scene {
    Settings {
      EmptyView()
    }
  }
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {

  public var statusItem: NSStatusItem?
  private var popOver = NSPopover()
  private var container = DIContainer(param: .production)
  private var isAppOpen = false

  @MainActor func applicationDidFinishLaunching(_ notification: Notification) {
    popOver.setValue(true, forKeyPath: "shouldHideAnchor")
    popOver.contentSize = CGSize(width: 275, height: 225)
    popOver.appearance = NSAppearance(named: .aqua)
    popOver.behavior = .transient
    popOver.animates = true
    popOver.contentViewController = NSHostingController(
      rootView: ContentView()
        .background(.clear)
        .textEditorCommand()
        .environment(\.injected, container)
        .environment(\.popOver, popOver)
        .hotkey(
          key: .kVK_ANSI_S, keyBase: [KeyBase.command, .option],
          action: {
            self.togglePopover()
          })
    )

    makePopoverTransparent(popOver)

    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    //        _ = container.appstate.pubOpenMenubarAppTrigger.sink { self.isAppOpen = $0 }

    if let statusButton = statusItem?.button {
      #if DEBUG
        statusButton.image = NSImage(
          systemSymbolName: "tortoise.fill", accessibilityDescription: nil)
      #else
        statusButton.image = NSImage(systemSymbolName: "tortoise", accessibilityDescription: nil)
      #endif
      statusButton.action = #selector(togglePopover)
    }
  }

  @objc public func togglePopover() {
    if let button = statusItem?.button {
      //            self.container.interactor.system.pushOpenMenubarAppTrigger(self.isAppOpen)
      //            self.container.interactor.updater.checkForUpdates()
      self.popOver.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.maxY)
      makePopoverTransparent(popOver)
    }
  }

  func makePopoverTransparent(_ popOver: NSPopover) {
    DispatchQueue.main.async {
      if let window = popOver.contentViewController?.view.window {

        // Ensure these modifications maintain transparency.
        window.isOpaque = false
        window.backgroundColor = .clear

        // Disable shadows for the pop-over content.
        window.hasShadow = false

        // Remove any visual effect background, such as NSVisualEffectView if present
        if let effectView = window.contentView?.superview?.subviews.first(where: {
          $0 is NSVisualEffectView
        }) as? NSVisualEffectView {
          effectView.state = .inactive
          effectView.isHidden = true

          // Optionally, set the alpha to 0 instead of just hiding it.
          effectView.alphaValue = 0.0
        }
      }
    }
  }
}

extension NSPopover: @retroactive EnvironmentKey {
  public static var defaultValue: NSPopover { NSPopover() }
}

extension EnvironmentValues {
  public var popOver: NSPopover {
    get { self[NSPopover.self] }
    set { self[NSPopover.self] = newValue }
  }
}

private struct KeyboardEventModifier: ViewModifier {
  enum Key: String {
    case a, c, v, x
  }

  let key: Key
  let modifiers: EventModifiers

  func body(content: Content) -> some View {
    content.keyboardShortcut(KeyEquivalent(Character(key.rawValue)), modifiers: modifiers)
  }
}

extension View {
  fileprivate func keyboardShortcut(
    _ key: KeyboardEventModifier.Key, modifiers: EventModifiers = .command
  ) -> some View {
    modifier(KeyboardEventModifier(key: key, modifiers: modifiers))
  }
}

extension View {
  func textEditorCommand() -> some View {
    self
      .hotkey(key: .kVK_ANSI_A, keyBase: [KeyBase.command]) {
        NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: nil)
      }
      .hotkey(key: .kVK_ANSI_C, keyBase: [KeyBase.command]) {
        NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: nil)
      }
      .hotkey(key: .kVK_ANSI_X, keyBase: [KeyBase.command]) {
        NSApp.sendAction(#selector(NSText.cut(_:)), to: nil, from: nil)
      }
      .hotkey(key: .kVK_ANSI_V, keyBase: [KeyBase.command]) {
        NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: nil)
      }
      .hotkey(key: .kVK_ANSI_Z, keyBase: [KeyBase.command]) {
        NSApp.sendAction(Selector(("undo:")), to: nil, from: nil)
      }
      .hotkey(key: .kVK_ANSI_Z, keyBase: [KeyBase.shift, KeyBase.command]) {
        NSApp.sendAction(Selector(("redo:")), to: nil, from: self)
      }
  }
}

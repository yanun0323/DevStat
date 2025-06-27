import Sparkle
//
//  DevStatApp.swift
//  DevStat
//
//  Created by yanun.y on 2024/8/14.
//
import SwiftUI
import SwiftData

@main
struct DevStatApp: App {
  // @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
  // @Environment(\.scenePhase) var scenePhase
  @AppStorage("showMenuBarExtra") private var showMenuBarExtra = true
  private let container = DIContainer(param: .production)

  var body: some Scene {
    Settings {
      EmptyView()
    }

    MenuBarExtra(
      "DevStat", systemImage: "tortoise",
      isInserted: $showMenuBarExtra
    ) {
      ContentView()
        // .background(.clear)
        .textEditorCommand()
        .environment(\.injected, container)
        .globalHotkey()
        .modelContainer(for: [OTP.self], isAutosaveEnabled: true)
    }
    .defaultSize(width: 275, height: 325)
    .menuBarExtraStyle(.window)
  }
}

// MARK: - Separated Components
@MainActor
class MenuBarManager: ObservableObject {
  private var statusItem: NSStatusItem?
  private var popover: NSPopover?

  func setupMenuBar(with contentView: some View) {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let popover = createPopover(with: AnyView(contentView))

    setupStatusButton(statusItem)

    self.statusItem = statusItem
    self.popover = popover
  }

  private func createPopover(with contentView: AnyView) -> NSPopover {
    let popover = NSPopover()
    popover.setValue(true, forKeyPath: "shouldHideAnchor")
    popover.contentSize = CGSize(width: 275, height: 400)
    popover.appearance = NSAppearance(named: .aqua)
    popover.behavior = .transient
    popover.animates = true

    let controller = NSHostingController(rootView: contentView)
    controller.view.wantsLayer = true
    controller.view.layer?.backgroundColor = .clear
    controller.view.layer?.masksToBounds = true
    controller.view.layer?.cornerRadius = 10
    controller.view.layer?.borderColor = NSColor.black.cgColor
    controller.view.layer?.shadowColor = NSColor.clear.cgColor
    controller.view.layer?.shadowOpacity = 0
    controller.view.layer?.isOpaque = false
    controller.view.layer?.backgroundColor = NSColor.clear.cgColor
    controller.view.layer?.shadowRadius = 0
    controller.view.layer?.shadowPath = nil
    popover.contentViewController = controller
    return popover
  }

  private func setupStatusButton(_ statusItem: NSStatusItem) {
    guard let button = statusItem.button else { return }

    #if DEBUG
      button.image = NSImage(systemSymbolName: "tortoise.fill", accessibilityDescription: nil)
    #else
      button.image = NSImage(systemSymbolName: "tortoise", accessibilityDescription: nil)
    #endif

    button.action = #selector(togglePopover)
    button.target = self
  }

  @objc private func togglePopover() {
    guard let button = statusItem?.button,
      let popover = popover
    else { return }

    if popover.isShown {
      popover.performClose(nil)
    } else {
      popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
    }
  }
}

// MARK: - Simplified AppDelegate
@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
  private let container = DIContainer(param: .production)
  private let menuBarManager = MenuBarManager()

  func applicationDidFinishLaunching(_ notification: Notification) {
    setupMenuBar()
  }

  private func setupMenuBar() {
    let contentView = ContentView()
      .background(.clear)
      .textEditorCommand()
      .environment(\.injected, container)
      .globalHotkey()

    menuBarManager.setupMenuBar(with: contentView)
  }
}

// MARK: - Global Hotkey Extension
extension View {
  func globalHotkey() -> some View {
    self.hotkey(
      key: .kVK_ANSI_S,
      keyBase: [KeyBase.command, .option]
    ) {
      // Use notification or delegate pattern instead of direct reference
      NotificationCenter.default.post(name: .toggleMenuBar, object: nil)
    }
  }
}

extension Notification.Name {
  static let toggleMenuBar = Notification.Name("toggleMenuBar")
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

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
        .textEditorCommand()
        .environment(\.injected, container)
        .modelContainer(for: [OTP.self], isAutosaveEnabled: true)
    }
    .defaultSize(width: 275, height: 315)
    .menuBarExtraStyle(.window)
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

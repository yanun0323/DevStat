import Sparkle
import SwiftUI
import SwiftData

struct ContentView: View {
  @Environment(\.injected) private var container
  @State private var error: Error?

  private let version =
    "v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-")"

  var body: some View {
    VStack {
      HStack(spacing: 6) {
        HStack(alignment: .bottom, spacing: 5) {
          Text("DevStat")
            .font(.system(size: 14))
            .kerning(1)
            .opacity(0.8)

          Text(version)
            .opacity(0.2)
            .font(.caption)
        }

        Spacer(minLength: 0)

        UpdaterView()

        Button(role: .destructive) {
          NSApplication.shared.terminate(self)
        } label: {
          Image(systemName: "power")
            .font(.system(.caption, weight: .medium))
            .foregroundColor(.white)
            .frame(width: 20, height: 18)
            .background(Color.red)
            .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        .buttonStyle(.plain)
      }
      .padding([.horizontal, .top])

      TimestampView()
        
      TotpView()
            .padding(.horizontal)
        
      Spacer()
    }
    .monospacedDigit()
    .onReceive(container.state.error) { error = $0 }
  }
}

#if DEBUG
  #Preview {
    ContentView()
      .inject(.inMemory)
      .frame(width: 275, height: 300)
      .modelContainer(for: [OTP.self], inMemory: true)
  }
#endif

struct glass: ViewModifier {
  func body(content: Content) -> some View {
    if #available(macOS 26.0, *) {
      content
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 15))
    } else {
      content
    }
  }
}

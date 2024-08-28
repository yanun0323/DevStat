import SwiftUI
import Sparkle

struct ContentView: View {
    @Environment(\.injected) private var container
    @State private var error: Error?
    
    private let version = "v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-")"

    var body: some View {
        VStack {
            HStack(spacing: 6) {
                HStack(alignment: .bottom, spacing: 5) {
                    Text("時間轉換工具")
                        .font(.system(size: 14))
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
        }
        .monospacedDigit()
        .onReceive(container.state.error) { error = $0 }
    }
}

#if DEBUG
#Preview {
    ContentView()
        .inject(.inMemory)
}
#endif

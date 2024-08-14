import SwiftUI

struct ContentView: View {
    @Environment(\.injected) private var container
    @State private var error: Error?

    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Button(role: .destructive) {
                    NSApplication.shared.terminate(self)
                } label: {
                    Image(systemName: "power")
                        .font(.system(.caption, weight: .medium))
                        .foregroundColor(.white)
                }
                .buttonStyle(.plain)
                .padding(.vertical, 2)
                .padding(.horizontal, 10)
                .background(Color.red)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .shadow(radius: 15)
            }
            
            TimestampView()
        }
        .padding()
        .onReceive(container.state.error) { error = $0 }
    }
}

#if DEBUG
#Preview {
    ContentView()
        .inject(.inMemory)
}
#endif

import SwiftUI
import Sparkle

struct UpdaterView: View {
    var updater = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil).updater
    var body: some View {
        Button {
            updater.checkForUpdates()
        } label: {
            Text("check update")
                .opacity(0.8)
                .font(.system(.caption, weight: .regular))
                .foregroundColor(.white)
                .frame(width: 85, height: 18)
                .background(Color.gray.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
#Preview {
    UpdaterView()
}
#endif

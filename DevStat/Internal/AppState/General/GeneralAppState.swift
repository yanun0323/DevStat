import SwiftUI
import Combine

struct GeneralAppState: AppStateDelegate {
    var _error = Channel<Error>()
}

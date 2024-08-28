import SwiftUI
import Combine

struct MockAppState: AppStateDelegate {
    var _error = Channel<Error>()
    var _timezone = Store<TimeZone>(.current)
}

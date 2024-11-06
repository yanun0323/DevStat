import SwiftUI
import Combine

struct GeneralAppState: AppStateDelegate {
    var _error = Channel<Error>()
    var _timezone = Store<TimeZone>(.current)
    var _timeDigit = Store<TimeDigit>(.second)
}

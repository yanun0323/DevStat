import SwiftUI

protocol AppStateDelegate: AppState {
    var _error: Channel<Error> { get }
    var _timezone: Store<TimeZone> { get }
    var _timeDigit: Store<TimeDigit> { get }
}

extension AppStateDelegate {
    var error: AnyProducer<Error> {
        return _error.eraseToAnyPublisher()
    }
    
    var timezone: AnyProducer<TimeZone> {
        return _timezone.eraseToAnyPublisher()
    }
    
    var timeDigit: AnyProducer<TimeDigit> {
        return _timeDigit.eraseToAnyPublisher()
    }
}

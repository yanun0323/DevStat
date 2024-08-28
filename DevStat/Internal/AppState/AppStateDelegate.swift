import SwiftUI

protocol AppStateDelegate: AppState {
    var _error: Channel<Error> { get }
    var _timezone: Store<TimeZone> { get }
}

extension AppStateDelegate {
    var error: AnyProducer<Error> {
        return _error.eraseToAnyPublisher()
    }
    
    var timezone: AnyProducer<TimeZone> {
        return _timezone.eraseToAnyPublisher()
    }
}

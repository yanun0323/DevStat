import SwiftUI

protocol AppStateDelegate: AppState {
    var _error: Channel<Error> { get }
}

extension AppStateDelegate {
    var error: AnyProducer<Error> {
        return _error.eraseToAnyPublisher()
    }
}

import SwiftUI
import Combine

typealias AnyProducer<T> = AnyPublisher<T, Never>
typealias Store<T> = CurrentValueSubject<T, Never>
typealias Channel<T> = PassthroughSubject<T, Never>

protocol AppState {
    var error: AnyProducer<Error> { get }
    var timezone: AnyProducer<TimeZone> { get }
}

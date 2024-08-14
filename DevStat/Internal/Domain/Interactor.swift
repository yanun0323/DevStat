import SwiftUI

protocol Interactor {
    var system: SystemInteractor { get }
}

protocol SystemInteractor {
    func sendError(_ err: Error)
}
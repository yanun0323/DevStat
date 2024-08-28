import SwiftUI

protocol Interactor {
    var system: SystemInteractor { get }
}

protocol SystemInteractor {
    func sendError(_ err: Error)
    func fetchTimezone()
    func setTimezone(_ timezone: TimeZone)
}

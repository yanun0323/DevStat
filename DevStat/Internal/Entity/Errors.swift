import SwiftUI

enum Errors: Error {
    case unknown
    case info(String)
    case warn(String)
    case error(String)
}

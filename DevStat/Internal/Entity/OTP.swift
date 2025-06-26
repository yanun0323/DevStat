import SwiftUI
import SwiftData

@Model
class OTP {
    var secrete: String
    
    init(secrete: String) {
        self.secrete = secrete
    }
}

extension OTP: Identifiable {
    var id: String { secrete }
}

import SwiftUI
import SwiftData

@Model
final class OTP {
    var title: String = "OTP"
    var secrete: String = ""
    var createdAt: Int64 = Date.now.unixMilli
    
    init(title: String, secrete: String) {
        self.title = title
        self.secrete = secrete
    }
}

extension OTP: Identifiable {
    var id: String { secrete }
}

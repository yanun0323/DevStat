import SwiftUI

enum TimeDigit: String, CaseIterable {
    case second = "Second"
    case millisecond = "Millisecond"
    case autoDetect = "Auto Detect"
}

extension TimeDigit: Identifiable {
    var id: String { self.rawValue }
}

extension Int64 {
    func secondToMilli(_ origin: TimeDigit) -> Int64 {
        switch origin {
            case .second:
                return self*1000
            case .millisecond:
                return self
            case .autoDetect:
                if self.description.count >= 13 {
                    return self /* millisecond */
                }
                
                return self*1000 /* second */
        }
    }
    
    func milliToSecond(_ origin: TimeDigit) -> Int64 {
        switch origin {
            case .second:
                return self
            case .millisecond:
                return self/1000
            case .autoDetect:
                if self.description.count >= 13 {
                    return self/1000 /* Millisecond */
                }
                
                return self /* second */
        }
    }
    
    func timeInterval(_ origin: TimeDigit) -> TimeInterval {
        let t = TimeInterval(self)
        switch origin {
            case .second:
                return t
            case .millisecond:
                return t/1000
            case .autoDetect:
                if self.description.count >= 13 {
                    return t/1000 /* Millisecond */
                }
                
                return t /* second */
        }
    }
}

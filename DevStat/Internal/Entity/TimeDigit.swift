import SwiftUI

enum TimeDigit: String, CaseIterable {
  case second = "Second"
  case millisecond = "Millisecond"
  case microsecond = "Microsecond"
  case autoDetect = "Auto Detect"
}

extension TimeDigit: Identifiable {
  var id: String { self.rawValue }
  var string: String {
    switch self {
    case .second, .millisecond, .microsecond:
      return self.rawValue
    case .autoDetect:
      return "Auto"
    }
  }
}

extension Int64 {
  func toSecond(_ origin: TimeDigit) -> Int64 {
    switch origin {
    case .second:
      return self
    case .millisecond:
      return self / 1_000
    case .microsecond:
      return self / 1_000_000
    case .autoDetect:
      if self.description.count >= 14 {
        return toSecond(.microsecond)
      }

      if self.description.count >= 11 {
        return toSecond(.millisecond)
      }

      return toSecond(.second)
    }
  }

  func toMillisecond(_ origin: TimeDigit) -> Int64 {
    switch origin {
    case .second:
      return self
    case .millisecond:
      return self * 1_000
    case .microsecond:
      return self / 1_000
    case .autoDetect:
      if self.description.count >= 14 {
        return toMillisecond(.microsecond)
      }

      if self.description.count >= 11 {
        return toMillisecond(.millisecond)
      }

      return toMillisecond(.second)
    }
  }

  func toMicrosecond(_ origin: TimeDigit) -> Int64 {
    switch origin {
    case .second:
      return self * 1_000_000
    case .millisecond:
      return self * 1_000
    case .microsecond:
      return self
    case .autoDetect:
      if self.description.count >= 14 {
        return toMillisecond(.microsecond)
      }

      if self.description.count >= 11 {
        return toMillisecond(.millisecond)
      }

      return toMillisecond(.second)
    }
  }

  func timeInterval(_ origin: TimeDigit) -> TimeInterval {
    let t = TimeInterval(self)
    switch origin {
    case .second:
      return t
    case .millisecond:
      return t / 1_000
    case .microsecond:
      return t / 1_000_000
    case .autoDetect:
      if self.description.count >= 14 {
        return timeInterval(.microsecond)
      }

      if self.description.count >= 11 {
        return timeInterval(.millisecond)
      }

      return timeInterval(.second)
    }
  }
}

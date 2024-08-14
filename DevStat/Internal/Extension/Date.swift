import SwiftUI

// MARK: Date Static function
extension Date {
    public init?(from date: String, _ layout: DateFormatLayout, _ locale: Locale = Locale.current, _ timezone: TimeZone? = nil) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = layout
        dateFormatter.locale = locale
        dateFormatter.timeZone = timezone
        guard let result = dateFormatter.date(from: date) else { return nil }
        self = result
    }
    
    public init(_ unixDay: Int) {
        self = Date(timeIntervalSince1970: TimeInterval(unixDay * 86_400))
    }
}

extension Date {
    /** Return the second for 1970-01-01 00:00:00 UTC */
    public var unix: Int { Int(self.timeIntervalSince1970) }
    
    public func string(_ layout: DateFormatLayout = .Default, _ locale: Locale = .autoupdatingCurrent) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = layout
        dateFormatter.locale = locale
        dateFormatter.timeZone = locale.timeZone
        return dateFormatter.string(from: self)
    }
}


// MARK: - DateFormatLayout
public typealias DateFormatLayout = String

extension DateFormatLayout {
    public init(_ layout: String) { self = layout }
    /**
     2006-01-02 15:04:05 +0800
     */
    public static let Default: Self = "yyyy-MM-dd HH:mm:ss Z"
    /**
     Mon Jan 02 15:04:05 2006
     */
    public static let ANSIC: Self = "EE MMM dd HH:mm:ss yyyy"
    /**
     Mon Jan 02 15:04:05 +0800 2006
     */
    public static let UnixDate: Self = "EE MMM dd HH:mm:ss Z yyyy"
    /**
     02 Jan 06 15:04 +0800
     */
    public static let RFC822: Self = "dd MMM yy HH:mm Z"
    /**
     Mon, 02 Jan 2006 15:04:05 +0800
     */
    public static let RFC1123: Self = "EE, dd MMM yyyy HH:mm:ss Z"
    /**
     Jan 02 15:04:05
     */
    public static let Stamp: Self = "MMM dd HH:mm:ss"
    /**
     2006-01-02
     */
    public static let Date: Self = "yyyy-MM-dd"
    /**
     20060102
     */
    public static let Numeric: Self = "yyyyMMdd"
}

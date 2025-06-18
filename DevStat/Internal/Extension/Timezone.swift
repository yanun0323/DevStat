import SwiftUI

extension TimeZone {
    static let timezones = timezoneTable()
    static func timezoneTable() -> [TimeZone] {
        var result: [TimeZone] = []
        var map: Dictionary<String, TimeZone> = [:]
        TimeZone.knownTimeZoneIdentifiers.map({ TimeZone(identifier: $0) }).forEach { tz in
            guard let tz = tz else { return }
            let key = Date.now.string("ZZ", timezone: tz)
            print("\(tz.identifier) - \(key)")
            if map[key] != nil { return }
            map[key] = tz
            result.append(tz)
        }
        
        result.sort(by: { Int(Date.now.string("ZZ", timezone: $0)) ?? 0 < Int(Date.now.string("ZZ", timezone: $1)) ?? 0 })
        return result
    }
}

extension TimeZone: @retroactive Identifiable {
    public var id: Int { self.secondsFromGMT()}
}

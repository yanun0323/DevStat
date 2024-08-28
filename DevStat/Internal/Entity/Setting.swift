import SwiftUI

enum SettingType: Int64 {
    case string
    case int
}

struct Setting {
    let key: String
    let type: SettingType
    let stringValue: String
    let intValue: Int64
    let createAt: Date
    let updateAt: Date
    
    init(key: String, type: SettingType, stringValue: String = "", intValue: Int64 = 0, createAt: Date = Date(), updateAt: Date = Date()) {
        self.key = key
        self.type = type
        self.stringValue = stringValue
        self.intValue = intValue
        self.createAt = createAt
        self.updateAt = updateAt
    }
}

extension Setting: Identifiable {
    var id: String { key }
}

extension Setting {
    func value() -> (String?, Int64?) {
        switch type {
            case .string:
                return (stringValue, nil)
            case .int:
                return (nil, intValue)
        }
    }
}

import SwiftUI
import SQLite
import Sworm

// MARK: - Log

extension LogType: Value {
    static func fromDatatypeValue(_ datatypeValue: Int64) throws -> LogType {
        return LogType(rawValue: datatypeValue) ?? .Info
    }
    
    var datatypeValue: Int64 {
        self.rawValue
    }
    
    static var declaredDatatype: String {
        return Int64.declaredDatatype
    }
}

extension Log: Model {
    static var tableName: String = "logs"
    
    static let id = Expression<Int64>("id")
    static let type = Expression<LogType>("type")
    static let message = Expression<String>("message")
    static let createAt = Expression<Date>("create_at")
    
    static func migrate(_ db: DB) throws {
        try db.run(table.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(type)
            t.column(message)
            t.column(createAt)
        })
    }
    
    static func parse(_ row: Row) throws -> Log {
        return Log(
            id: try row.get(id),
            type: try row.get(type),
            message: try row.get(message),
            createAt: try row.get(createAt)
        )
    }
    
    func setter() -> [Setter] {
        return [
            Log.type <- type,
            Log.message <- message,
            Log.createAt <- createAt
        ]
    }
}

// MARK: - Setting

extension SettingType: Value {
    static func fromDatatypeValue(_ datatypeValue: Int64) throws -> SettingType {
        return SettingType(rawValue: datatypeValue) ?? .string
    }
    
    var datatypeValue: Int64 {
        self.rawValue
    }
    
    static var declaredDatatype: String {
        return Int64.declaredDatatype
    }
}

extension Setting: Model {
    static var tableName: String = "settings"
    
    static let key = Expression<String>("key")
    static let type = Expression<SettingType>("type")
    static let stringValue = Expression<String>("string_value")
    static let intValue = Expression<Int64>("int_value")
    static let createAt = Expression<Date>("create_at")
    static let updateAt = Expression<Date>("update_at")
    
    static func migrate(_ db: DB) throws {
        try db.run(table.create(ifNotExists: true) { t in
            t.column(key, primaryKey: true)
            t.column(type)
            t.column(stringValue)
            t.column(intValue)
            t.column(createAt)
            t.column(updateAt)
        })
    }
    
    static func parse(_ row: Row) throws -> Setting {
        return Setting(
            key: try row.get(key),
            type: try row.get(type),
            stringValue: try row.get(stringValue),
            intValue: try row.get(intValue),
            createAt: try row.get(createAt),
            updateAt: try row.get(updateAt)
        )
    }
    
    func setter() -> [Setter] {
        let now = Date.now
        return [
            Setting.type <- type,
            Setting.stringValue <- stringValue,
            Setting.intValue <- intValue,
            Setting.createAt <- (createAt.unix == 0 ? now : createAt),
            Setting.updateAt <- now
        ]
    }
}


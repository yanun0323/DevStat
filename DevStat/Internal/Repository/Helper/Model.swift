import SwiftUI
import SQLite
import Sworm

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

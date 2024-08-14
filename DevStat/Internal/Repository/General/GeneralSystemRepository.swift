import SwiftUI
import Sworm
import SQLite

struct GeneralSystemRepository {
    let dao: Dao
}

extension GeneralSystemRepository: SystemRepository {
    func saveLog(_ log: Log) throws {
        let _:Int64 = try dao.insert(log)
    }

    func listLog(type: LogType?) throws -> [Log] {
        if let t = type {
            return try dao.query(Log.self, query: { $0.where(Log.type == t).order(Log.id.asc) })
        }

        return try dao.query(Log.self, query: { $0.order(Log.id.asc) })
    }
}

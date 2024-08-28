import SwiftUI
import Sworm

enum ErrRepository: Error {
    case recordNotFound
}

protocol Repository: BasicRepository {
    var system: SystemRepository { get }
    
    func tx(action: @escaping () throws -> Void, success: @escaping () -> Void, failed: @escaping (Error) -> Void)
}


protocol SystemRepository {
    func saveLog(_ log: Log) throws
    func listLog(type: LogType?) throws -> [Log]
}

extension SystemRepository {
    func listLog(_ type: LogType? = nil) throws -> [Log] {
        return try self.listLog(type: type)
    }
}

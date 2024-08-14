import SwiftUI

fileprivate extension Log {
    static let mocks: [Log] = [
        Log(id: 0, type: .Error, message: "error not found"),
        Log(id: 1, type: .Error, message: "error insert failed"),
        Log(id: 2, type: .Error, message: "error connection timeout")
    ]
}


class MockSystemRepository {
    private var cache: [Log] = Log.mocks
}

extension MockSystemRepository: SystemRepository {
    func saveLog(_ log: Log) throws {
        var lastID = Int64(0)
        cache.forEach({
            if $0.id > lastID {
                lastID = $0.id
            }
        })
        
        let id = lastID + 1
        let t = Log(id: id, type: log.type, message: log.message, createAt: log.createAt)
        cache.append(t)
    }

    func listLog(type: LogType?) throws -> [Log] {
        return cache
    }
}

import SwiftUI
import Sworm

struct Dao: BasicDao, BasicRepository  {
    let db: DB

    init(inMemory: Bool) {
        self.db = Sworm.setup(mock: inMemory)
        db.migrate(Log.self)
    }
}

struct GeneralRepository: Repository {
    private let dao: Dao
    var system: SystemRepository
    
    init(inMemory: Bool) {
        let dao = Dao(inMemory: inMemory)

        self.dao = dao
        self.system = GeneralSystemRepository(dao: dao)
    }
}

extension GeneralRepository {
    func tx(action: @escaping () throws -> Void, success: @escaping () -> Void, failed: @escaping (Error) -> Void) {
       dao.tx(action: action, success: success, failed: failed)
    }
}
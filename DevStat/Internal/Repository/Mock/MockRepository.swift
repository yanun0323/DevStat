import SwiftUI

struct MockRepository: Repository {
    var system: SystemRepository
    
    init() {
        self.system = MockSystemRepository()
    }
}

extension MockRepository {
    func tx(action: @escaping () throws -> Void, success: @escaping () -> Void, failed: @escaping (Error) -> Void) {
        do {
            try action()
            success()
        } catch {
            failed(error)
        }
    }
}
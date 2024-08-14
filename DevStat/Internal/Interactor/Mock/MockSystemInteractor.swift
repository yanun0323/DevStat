import SwiftUI

struct MockSystemInteractor {
    private let state: AppStateDelegate
    private let repo: Repository
    
    init(state: AppStateDelegate, repo: Repository) {
        self.state = state
        self.repo = repo
    }
}

extension MockSystemInteractor: SystemInteractor {
    func sendError(_ err: Error) {
        state._error.send(err)
    }
}

import SwiftUI

struct GeneralSystemInteractor {
    private let state: AppStateDelegate
    private let repo: Repository
    
    init(state: AppStateDelegate, repo: Repository) {
        self.state = state
        self.repo = repo
    }
}

extension GeneralSystemInteractor: SystemInteractor {
    func sendError(_ err: Error) {
        try? repo.system.saveLog(Log(type: .Error, message: "\(err)"))
        state._error.send(err)
    }
}

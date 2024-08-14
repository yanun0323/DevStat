import SwiftUI

struct MockInteractor: Interactor {
    var system: SystemInteractor
    
    init(state: AppStateDelegate, repo: Repository) {
        self.system = MockSystemInteractor(state: state, repo: repo)
    }
}

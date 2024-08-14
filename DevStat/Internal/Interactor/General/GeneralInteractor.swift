import SwiftUI

struct GeneralInteractor: Interactor {
    var system: SystemInteractor
    
    init(state: AppStateDelegate, repo: Repository) {
        self.system = GeneralSystemInteractor(state: state, repo: repo)
    }
}

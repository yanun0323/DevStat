import SwiftUI

// MARK: - DIContainerParam
struct DIContainerParam {
    let state: AppState
    let inter: Interactor
    let repo: Repository
}

extension DIContainerParam {
    static var production: DIContainerParam {
        let state = GeneralAppState()
        let repo = GeneralRepository(inMemory: false)
        let inter = GeneralInteractor(state: state, repo: repo)
        return DIContainerParam(state: state, inter: inter, repo: repo)
    }

    static var inMemory: DIContainerParam {
        let state = GeneralAppState()
        let repo = GeneralRepository(inMemory: true)
        let inter = GeneralInteractor(state: state, repo: repo)
        return DIContainerParam(state: state, inter: inter, repo: repo)
    }
    
    static var mock: DIContainerParam {
        let state = MockAppState()
        let repo = MockRepository()
        let inter = MockInteractor(state: state, repo: repo)
        return DIContainerParam(state: state, inter: inter, repo: repo)
    }
}

// MARK: - DIContainer
struct DIContainer {
    let state: AppState
    let inter: Interactor
    
    init(param: DIContainerParam) {
        self.state = param.state
        self.inter = param.inter
    }
}

#if DEBUG
extension DIContainer {
    static var preview: DIContainer {
        return DIContainer(param: .mock)
    }
    
    static var inMemory: DIContainer {
        return DIContainer(param: .inMemory)
    }
}
#endif

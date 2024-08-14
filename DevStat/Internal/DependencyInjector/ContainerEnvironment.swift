import SwiftUI

// MARK: - DIContainer Environment
extension DIContainer: EnvironmentKey {
    static var defaultValue: DIContainer {
        return DIContainer(param: .production)
    }
}

extension View {
    func inject(_ container: DIContainer) -> some View {
        self.environment(\.injected, container)
    }
}

extension EnvironmentValues {
    var injected: DIContainer {
        get { self[DIContainer.self] }
        set { self[DIContainer.self] = newValue }
    }
}

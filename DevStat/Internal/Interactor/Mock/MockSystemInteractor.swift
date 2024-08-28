import SwiftUI

private let timezoneKey = "TIMEZONE"

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
    
    func fetchTimezone() {
        let result: [Setting]? = try? repo.query(Setting.self, query: { $0.where(Setting.key.match(timezoneKey)) })
        guard let result = result, !result.isEmpty else {
            sendError(Errors.warn("fetchTimezone: setting not found. key: \(timezoneKey)"))
            state._timezone.send(.current)
            return
        }
        
        let setting = result.first!
        
        guard let tz = TimeZone(identifier: setting.stringValue) else {
            sendError(Errors.error("time zone is not valid: \(setting.stringValue)"))
            return
        }
        
        state._timezone.send(tz)
    }
    
    func setTimezone(_ timezone: TimeZone) {
        let result: Int? = try? repo.update(Setting(key: timezoneKey, type: .string, stringValue: timezone.identifier), query: { $0.where(Setting.key.match(timezoneKey)) })
        guard let result else {
            sendError(Errors.error("setTimezone: update timezone (\(timezone.identifier) failed"))
            return
        }
    }
}

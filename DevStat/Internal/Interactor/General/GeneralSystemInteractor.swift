import SwiftUI
import SQLite

private let timezoneKey = "TIMEZONE"
private let timeDigitKey = "TIME_DIGIT"

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
    
    func fetchTimezone() {
        do {
            let result: [Setting] = try repo.query(Setting.self, query: { $0.where(Setting.key == timezoneKey) })
            
            if result.isEmpty {
                return
            }

            let setting = result.first!
            
            guard let tz = TimeZone(identifier: setting.stringValue) else {
                sendError(Errors.error("time zone is not valid: \(setting.stringValue)"))
                return
            }
            
            state._timezone.send(tz)
        } catch {
            sendError(Errors.warn("fetchTimezone: setting not found. key: \(timezoneKey), err: \(error)"))
            state._timezone.send(.current)
        }
    }
    
    func setTimezone(_ timezone: TimeZone) {
        let setting = Setting(key: timezoneKey, type: .string, stringValue: timezone.identifier)
        do {
            let _: Int64 = try repo.upsert(setting, onConflictOf: Setting.key, primaryKey: timezoneKey)
            state._timezone.send(timezone)
        } catch {
            sendError(Errors.error("setTimezone: update timezone (\(timezone.identifier), err: \(error)"))
        }
    }
    
    func fetchTimeDigit() {
        do {
            let result: [Setting] = try repo.query(Setting.self, query: { $0.where(Setting.key == timeDigitKey) })
            
            if result.isEmpty {
                return
            }

            let setting = result.first!
            
            guard let td = TimeDigit(rawValue: setting.stringValue) else {
                sendError(Errors.error("time zone is not valid: \(setting.stringValue)"))
                return
            }
            
            state._timeDigit.send(td)
        } catch {
            sendError(Errors.warn("fetchTimezone: setting not found. key: \(timezoneKey), err: \(error)"))
            state._timeDigit.send(.second)
        }
    }
    
    func setTimeDigit(_ timeDigit: TimeDigit) {
        let setting = Setting(key: timeDigitKey, type: .string, stringValue: timeDigit.rawValue)
        do {
            let _: Int64 = try repo.upsert(setting, onConflictOf: Setting.key, primaryKey: timeDigitKey)
            state._timeDigit.send(timeDigit)
        } catch {
            sendError(Errors.error("setTimeDigit: update time digit (\(timeDigit.rawValue), err: \(error)"))
        }
    }
}

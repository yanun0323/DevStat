import SwiftUI

enum LogType: Int64 {
    case Info
    case Waring
    case Error
}

struct Log {
    let id: Int64
    let type: LogType
    let message: String
    let createAt: Date
    
    init(id: Int64 = 0, type: LogType, message: String, createAt: Date = Date.now) {
        self.id = id
        self.type = type
        self.message = message
        self.createAt = createAt
    }
    
}

extension Log: Identifiable {}

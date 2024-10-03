//
//  Logger.swift
//  Swap Money
//
//  Created by Akashlal Bathe on 29/09/24.
//

import Foundation

enum LogLevel : String {
    case debug = "Debug"
    case info = "Info"
    case warning = "Warning"
    case error = "Error"
}

protocol Loggable {
    func log(key: String, message: String, logLevel : LogLevel, additionalParams: [String: Any]?)
    func readValue(key: String) -> String?
    func isLogged(partOfMessage: String) -> Bool
    func clearLogs()
}

final class BasicLogger: Loggable {
    
    private let concurrentQueue = DispatchQueue(label: "concurrentQueue",
                                                attributes: .concurrent)
    private var logEvents: [String: Any] = [:]
    
    func log(key: String, message: String, logLevel: LogLevel, additionalParams: [String: Any]?) {
        concurrentQueue.asyncAndWait(flags: .barrier, execute: {
            let timestamp = DateFormatter.localizedString(from: Date(),
                                                          dateStyle: .short, timeStyle: .long)
            logEvents[key] = message
            debugPrint("\(timestamp) \(logLevel.rawValue) \(message)")
        })
    }
    
    func readValue(key: String) -> String? {
        var value: String?
        concurrentQueue.sync {
            value = logEvents[key] as? String
        }
        return value
    }
    
    func isLogged(partOfMessage: String) -> Bool {
        concurrentQueue.sync {
            for (_, message) in logEvents {
                if let message = message as? String, message.contains(partOfMessage) {
                    return true
                }
            }
            return false
        }
    }
    
    func clearLogs() {
        self.logEvents.removeAll(keepingCapacity: false)
    }
}

final class Logger {
    
    private init() {}
    static var sharedInstance = Logger()
    
    private var logger: any Loggable = BasicLogger()
    
    func switchLogger(with logger: Loggable) {
        self.logger = logger
    }
    
    func log(key: String = UUID().uuidString, message: String, logLevel : LogLevel = .info, additionalParams: [String: Any]? = nil) {
        self.logger.log(key: key, message: message, logLevel: logLevel, additionalParams: additionalParams)
    }
    
    func readValue(key: String) -> String? {
        self.logger.readValue(key: key)
    }
    
    func isLogged(partOfMessage: String) -> Bool {
        self.logger.isLogged(partOfMessage: partOfMessage)
    }
    
    func clearLogs() {
        self.logger.clearLogs()
    }
    
}

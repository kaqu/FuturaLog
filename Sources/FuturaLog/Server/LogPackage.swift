import Foundation

public struct LogPackage : Codable {
    
    public let applicationID: String
    public let sessionID: String
    public let environment: LogEnvironment
    public var logs: [Log]
    
    public init(applicationID: String, environment: LogEnvironment, sessionID: String = Logger.sessionID, logs: [Log]) {
        self.applicationID = applicationID
        self.sessionID = sessionID
        self.environment = environment
        self.logs = logs
    }
}

extension LogPackage {
    
    public func flatten() -> [FlatLog] {
        return logs.map { log in
            return FlatLog(applicationID: applicationID,
                           sessionID: sessionID,
                           environmentName: environment.name,
                           appVersion: environment.appVersion,
                           platform: environment.platform,
                           osInfo: environment.osInfo,
                           environmentInfo: environment.info,
                           category: log.category,
                           context: log.context,
                           timestamp: log.timestamp,
                           message: log.message)
        }
    }
}

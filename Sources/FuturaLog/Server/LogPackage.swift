import Foundation

public struct LogPackage : Codable {
    
    public let application: String
    public let applicationVersion: String?
    public let session: String
    public let environment: LogEnvironment
    public var logs: [Log]
    
    public init(application: String, applicationVersion: String?, environment: LogEnvironment, session: String, logs: [Log]) {
        self.application = application
        self.applicationVersion = applicationVersion
        self.session = session
        self.environment = environment
        self.logs = logs
    }
}

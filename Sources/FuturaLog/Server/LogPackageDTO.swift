import Foundation

public struct LogPackageDTO : Codable {
    
    public let application: String
    public let environment: String
    public let session: String
    public var logs: [Log]
    
    public init(application: String, environment: String, session: String, logs: [Log]) {
        self.application = application
        self.session = session
        self.environment = environment
        self.logs = logs
    }
}

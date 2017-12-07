import Foundation

public struct LogPackageDTO : Codable {
    
    internal let applicationID: String
    internal let sessionID: String
    internal let environment: String
    internal var logs: [Log]
}

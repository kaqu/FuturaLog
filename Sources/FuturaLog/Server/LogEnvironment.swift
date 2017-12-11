import Foundation

public struct LogEnvironment : Codable {
    
    public let name: String?
    public let type: String
    public let platform: String?
    public let operatingSystem: String?
    public let operatingSystemVersion: String?
    public let info: String?
}


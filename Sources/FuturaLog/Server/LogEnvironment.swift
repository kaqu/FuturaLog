import Foundation

public struct LogEnvironment : Codable {
    
    public let name: String?
    public let type: String
    public let applicationVersion: String?
    public let platform: String?
    public let operatingSystem: String?
    public let operatingSystemVersion: String?
    public let info: String?
    
    public init(name: String?, type: String, applicationVersion: String?, platform: String?, operatingSystem: String?, operatingSystemVersion: String?, info: String?) {
        self.name = name
        self.type = type
        self.applicationVersion = applicationVersion
        self.platform = platform
        self.operatingSystem = operatingSystem
        self.operatingSystemVersion = operatingSystemVersion
        self.info = info
    }
}


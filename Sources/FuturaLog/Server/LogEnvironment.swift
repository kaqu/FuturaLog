import Foundation

public struct LogEnvironment : Codable {
    
    public let name: String
    public let appVersion: String
    public let platform: String?
    public let osInfo: String?
    public let info: String?
    
    public init(name: String, appVersion: String, platform: String? = nil, osInfo: String? = nil, info: String? = nil) {
        self.name = name
        self.appVersion = appVersion
        self.platform = platform
        self.osInfo = osInfo
        self.info = info
    }
}

extension LogEnvironment : Hashable {
    
    public var hashValue: Int {
        return "\(self.name)\(self.appVersion)\(self.platform ?? "N/A")\(self.osInfo ?? "N/A")\(self.info ?? "N/A")".hashValue
    }
    
    public static func ==(lhs: LogEnvironment, rhs: LogEnvironment) -> Bool {
        return lhs.name == rhs.name &&
            lhs.appVersion == rhs.appVersion &&
            lhs.platform == rhs.platform &&
            lhs.osInfo == rhs.osInfo &&
            lhs.info == rhs.info
    }
}

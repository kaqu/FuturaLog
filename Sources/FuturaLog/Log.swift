import Foundation

public struct Log : Codable {
    
    public let category: LogCategory
    public let context: String?
    public let timestamp: Date
    public let message: String
    
    public init(_ category: LogCategory, context: String? = nil, timestamp: Date = Date(), message: String) {
        self.category = category
        self.context = context
        self.timestamp = timestamp
        self.message = message
    }
}

extension Log : ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        self.init(.debug, message: value)
    }
}

public enum LogCategory : String, Codable {
    
    case crash
    case special
    case error
    case warning
    case debug
    case verbose
    case info
    case void // not present in `all` property since void is special type which is ignored by default
    
    public static let all: [LogCategory] = [.crash, .special, .error, .warning, .debug, .verbose, .info]
}

import Foundation

public enum LogCategory : UInt8, Codable {
    
    case crash = 0b10000000
    case special = 0b01000000
    case error = 0b00100000
    case warning = 0b00010000
    case debug = 0b00001000
    case verbose = 0b00000100
    case message = 0b00000010
    case info = 0b00000001
    case void = 0b00000000
    
    public static let all: [LogCategory] = [.crash, .special, .error, .warning, .debug, .verbose, .message, .info, .void]
}

public struct Log : Codable {
    
    public let category: LogCategory
    public let context: String?
    public let timestamp: Date
    public let message: String
    
    public init(_ category: LogCategory, context: String? = #function, timestamp: Date = Date(), message: @autoclosure ()->(String)) {
        self.category = category
        self.context = context
        self.timestamp = timestamp
        self.message = message()
    }
}

extension Log : ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        self.init(.debug, context: nil, message: value)
    }
}

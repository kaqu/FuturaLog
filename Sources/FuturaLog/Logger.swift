import Foundation

public final class Logger {

    fileprivate static var recivers: Array<LogReciver> = []
    
    public static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()
    
    public static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        return encoder
    }()
}

public extension Logger {
    
    static func addReciver(_ reciver: LogReciver) {
        recivers.append(reciver)
    }
    
    static func send(_ log: Log) {
        recivers.forEach { $0.recive(log) }
    }
    
    static func flush() {
        recivers.forEach { $0.flush() }
    }
}

public extension Logger {

    static func error(_ message: String, function: String = #function, line: Int = #line) {
        send(Log(.error, context: "\(function)\(line)", message: message))
    }
    
    static func warning(_ message: String, function: String = #function, line: Int = #line) {
        send(Log(.warning, context: "\(function)\(line)", message: message))
    }
    
    static func debug(_ message: String, function: String = #function, line: Int = #line) {
        send(Log(.debug, context: "\(function)\(line)", message: message))
    }
    
    static func verbose(_ message: String, function: String = #function, line: Int = #line) {
        send(Log(.verbose, context: "\(function)\(line)", message: message))
    }
    
    static func info(_ message: String, function: String = #function, line: Int = #line) {
        send(Log(.info, context: "\(function)\(line)", message: message))
    }
}

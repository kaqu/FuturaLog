import Foundation

public final class Logger {

    fileprivate static var recievers: Array<LogReceiver> = []
    
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
    
    static func addReciever(_ reciever: LogReceiver) {
        recievers.append(reciever)
    }
    
    static func send(_ log: Log) {
        recievers.forEach { $0.recieve(log) }
    }
    
    static func flush() {
        recievers.forEach { $0.flush() }
    }
}

public extension Logger {

    static func error(_ message: String, function: String = #function, line: Int = #line) {
        send(Log(.error, context: "\(function):\(line)", message: message))
    }
    
    static func warning(_ message: String, function: String = #function, line: Int = #line) {
        send(Log(.warning, context: "\(function):\(line)", message: message))
    }
    
    static func debug(_ message: String, function: String = #function, line: Int = #line) {
        send(Log(.debug, context: "\(function):\(line)", message: message))
    }
    
    static func verbose(_ message: String, function: String = #function, line: Int = #line) {
        send(Log(.verbose, context: "\(function):\(line)", message: message))
    }
    
    static func info(_ message: String, function: String = #function, line: Int = #line) {
        send(Log(.info, context: "\(function):\(line)", message: message))
    }
}

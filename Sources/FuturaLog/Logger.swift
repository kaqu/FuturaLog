import Foundation

public final class Logger {

    fileprivate static var recivers: Array<LogReciver> = []
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

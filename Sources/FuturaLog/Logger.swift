import Foundation

public final class Logger {
    
    public static let sessionID: String = UUID().uuidString
    
    fileprivate static var recievers: Array<LogReceiver> = []
    fileprivate static let logsQueue = DispatchQueue(label: "futura.log.mainQueue", qos: .utility)
}

public extension Logger {
    
    static func addReciever(_ reciever: LogReceiver) {
        logsQueue.async { recievers.append(reciever) }
    }
    
    static func send(_ log: Log) {
        logsQueue.async { recievers.forEach { $0.recieve(log) } }
    }
    
    static func flush() {
        logsQueue.sync { recievers.forEach { $0.flush() } }
    }
}

public extension Logger {
    
    static func send(_ logCategory: LogCategory = .debug, message: String, function: String = #function, line: Int = #line) {
        send(Log(logCategory, context: "\(function):\(line)", message: message))
    }
}

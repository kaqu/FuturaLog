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

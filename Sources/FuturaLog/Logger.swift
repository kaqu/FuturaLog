import Foundation

public final class Logger {

    fileprivate static var recivers: Array<LogReciver> = []
}

public extension Logger {
    
    static func addReciver(_ reciver: LogReciver) {
        recivers.append(reciver)
    }
    
    static func send(_ log: Log) {
        recivers.forEach { $0.send(log) }
    }
}


internal extension Logger {

    static func flushAll() {
        recivers = []
        sleep(3) // wait for log flush -- TODO: find better way
    }
}

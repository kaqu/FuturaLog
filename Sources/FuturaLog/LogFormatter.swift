import Foundation

// TODO: to refactor - enable more flexible formatting
public final class LogFormatter {
    
    fileprivate let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS ZZZZZZZZ"
        return formatter
    }()
    
    public func format(_ log: Log) -> String {
        return "\(formatCategory(of: log))(\(formatTimestamp(of: log)))\(formatContext(of: log)):\(log.message)"
    }
    
    public static var `default`: LogFormatter {
        return LogFormatter()
    }
}

fileprivate extension LogFormatter {
    
    func formatCategory(of log: Log) -> String {
        switch log.category {
        case .crash:
            return "[CRASH]"
        case .special:
            return "[SPECIAL]"
        case .error:
            return "[ERROR]"
        case .warning:
            return "[WARNING]"
        case .debug:
            return "[DEBUG]"
        case .verbose:
            return "[VERBOSE]"
        case .message:
            return "[MESSAGE]"
        case .info:
            return "[INFO]"
        case .void:
            return ""
        }
    }
    
    func formatTimestamp(of log: Log) -> String {
        return dateFormatter.string(from:log.timestamp)
    }
    
    func formatContext(of log: Log) -> String {
        guard let context = log.context else {
            return ""
        }
        return "<\(context)>"
    }
}

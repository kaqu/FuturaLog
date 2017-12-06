import Foundation

public final class LogFilePrinter : LogReciver {
    
    public let allowedCategories: [LogCategory]
    
    private let synchronizationQueue = DispatchQueue(label: "futura.log.printer.syncQueue")
    private let formatter: LogFormatter
    
    private let filePath: String
    private let storage: FileHandle
    
    private let mode: Mode
    
    private let delimitter: Data
    private let encoding: String.Encoding
    
    public func send(_ log: Log) {
        synchronizationQueue.async {
            guard self.allowedCategories.contains(log.category) else {
                return
            }
            let logString = self.formatter.format(log)
            guard var logData = logString.data(using: self.encoding) else {
                return
            }
            logData.append(self.delimitter)
            self.storage.write(logData)
        }
    }
    
    public init?(for categories: [LogCategory] = LogCategory.all, with mode: Mode = .append, on filePath: String, formatter: LogFormatter = LogFormatter.default, delimitter: String = "\u{FFFF}\n", encoding: String.Encoding = .utf8) {
        self.allowedCategories = categories
        self.mode = mode
        self.encoding = encoding
        self.filePath = filePath
        
        guard let delimitter = delimitter.data(using: encoding) else {
            return nil
        }
        
        self.delimitter = delimitter
        
        self.formatter = formatter
        
        if !FileManager.default.fileExists(atPath: filePath) {
            FileManager.default.createFile(atPath: filePath, contents: Data(), attributes: nil)
        } else { /* nothing */ }
        
        guard let storage = FileHandle(forWritingAtPath: filePath) else {
            return nil
        }
        self.storage = storage
        
        switch mode {
        case .append:
            self.storage.seekToEndOfFile()
        case .wipe:
            self.storage.truncateFile(atOffset: 0)
        }
    }
    
    public func flush() {
        storage.synchronizeFile()
    }
}


extension LogFilePrinter {
    
    public enum Mode {
        case append
        //    case cycle(logCount: UInt)
        case wipe
    }
}

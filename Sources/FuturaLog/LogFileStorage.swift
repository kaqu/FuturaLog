import Foundation

// TODO: add cycling storage, session separated and date separated modes
public final class LogFileStorage : LogReciver {
    
    fileprivate let synchronizationQueue = DispatchQueue(label: "futura.log.storage.file.syncQueue")
    
    public let allowedCategories: [LogCategory]
    
    private let filePath: String
    private let storage: FileHandle
    
    private let mode: Mode
    
    private let delimitter: Data
    private let encoding: String.Encoding
    
    public var reader: Reader {
        return Reader(of: self)
    }
    
    public func recive(_ log: Log) {
        synchronizationQueue.async {
            guard self.allowedCategories.contains(log.category) else {
                return
            }
            
            guard var logData = try? JSONEncoder().encode(log) else {
                return
            }
            logData.append(self.delimitter)
            self.storage.write(logData)
        }
    }
    
    public init?(for categories: [LogCategory] = LogCategory.all, inMode mode: Mode = .append, usingDirectory directory: URL, encoding: String.Encoding = .utf8, withDelimitter delimitter: String = "\u{FFFF}\n") {
        precondition(!directory.isFileURL, "When crateing LogFileStorage use directory without specifying file name")
        self.allowedCategories = categories
        self.mode = mode
        self.encoding = encoding
        self.filePath = directory.appendingPathComponent("logs.ftlog").path
        
        guard let delimitter = delimitter.data(using: encoding) else {
            return nil
        }
        
        self.delimitter = delimitter
        
        if !FileManager.default.fileExists(atPath: filePath) {
            FileManager.default.createFile(atPath: filePath, contents: Data(), attributes: nil)
        } else { /* nothing */ }
        
        guard let storage = FileHandle(forUpdatingAtPath: filePath) else {
            return nil
        }
        self.storage = storage
        
        switch mode {
        case .append:
            self.storage.seekToEndOfFile()
        case .clean:
            self.storage.truncateFile(atOffset: 0)
        }
    }
    
    public func flush() {
        synchronizationQueue.sync {
            storage.synchronizeFile()
        }
    }
    
    deinit {
        synchronizationQueue.sync {
            storage.synchronizeFile()
            storage.closeFile()
        }
    }
}

extension LogFileStorage {
    
    public enum Mode {
        case append
        case clean
    }
}

extension LogFileStorage {
    
    public struct Reader : LogStorageReader {
        
        private let synchronizationQueue: DispatchQueue
        
        private let delimitter: Data
        private let encoding: String.Encoding
        
        private let bufferSize: Int = 256
        private var readBuffer: NSMutableData = NSMutableData(capacity: 256)!
        
        private let readHandle: FileHandle
        
        fileprivate init(of storage: LogFileStorage) {
            self.readHandle = FileHandle(forReadingAtPath: storage.filePath)!
            self.delimitter = storage.delimitter
            self.encoding = storage.encoding
            self.synchronizationQueue = storage.synchronizationQueue
        }
        
        public mutating func next() -> Log? {
            var range = readBuffer.range(of: delimitter, options: [], in: NSMakeRange(0, readBuffer.length))
            while range.location == NSNotFound {
                let tmpData = synchronizationQueue.sync { readHandle.readData(ofLength: bufferSize) }
                if tmpData.count == 0 {
                    
                    if readBuffer.length > 0 {
                        let log = try? JSONDecoder().decode(Log.self, from: readBuffer as Data)
                        readBuffer.length = 0
                        return log
                    }
                    return nil
                }
                readBuffer.append(tmpData)
                range = readBuffer.range(of: delimitter, options: [], in: NSMakeRange(0, readBuffer.length))
            }
            
            let log = try? JSONDecoder().decode(Log.self, from: readBuffer.subdata(with: NSMakeRange(0, range.location)))
            readBuffer.replaceBytes(in: NSMakeRange(0, range.location + range.length), withBytes: nil, length: 0)
            
            return log
        }
        
        public mutating func rewind() {
            readHandle.seek(toFileOffset: 0)
        }
    }
}

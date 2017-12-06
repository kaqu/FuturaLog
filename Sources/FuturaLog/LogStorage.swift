import Foundation

public protocol LogStorageReader : Sequence, IteratorProtocol {
    mutating func rewind()
}

public final class LogMemoryStorage : LogReciver {
    
    public let allowedCategories: [LogCategory]
    private let synchronizationQueue = DispatchQueue(label: "futura.log.storage.memory.syncQueue")
    private let capacity: UInt
    
    private var storage: [Log]
    
    public func send(_ log: Log) {
        synchronizationQueue.async {
            guard self.allowedCategories.contains(log.category) else {
                return
            }
            if self.storage.count < self.capacity {
                self.storage.append(log)
            } else {
                self.storage.removeFirst(1)
                self.storage.append(log)
            }
        }
    }
    
    public init(for categories: [LogCategory] = LogCategory.all, withCapacity capacity: UInt = UInt.max) {
        self.allowedCategories = categories
        self.capacity = capacity
        self.storage = []
    }
    
    public func flush() {}
}

extension LogMemoryStorage {
    
    public struct Reader : LogStorageReader {
        
        private weak var storage: LogMemoryStorage?
        private var index: Int = 0
        
        fileprivate init?(of storage: LogMemoryStorage) {
            self.storage = storage
        }
        
        public mutating func next() -> Log? {
            guard let storage = storage else {
                return nil
            }
            if storage.storage.count > index {
                return storage.storage[index]
            } else {
                return nil
            }
        }
        
        public mutating func rewind() {
            index = 0
        }
    }
}

// TODO: add cycling storage

public final class LogFileStorage : LogReciver {
    
    public let allowedCategories: [LogCategory]
    private let synchronizationQueue = DispatchQueue(label: "futura.log.storage.file.syncQueue")
    
    private let filePath: String
    private let storage: FileHandle
    
    private let mode: Mode
    
    private let delimitter: Data
    private let encoding: String.Encoding
    
    public var reader: Reader {
        return Reader(of: self)
    }
    
    public func send(_ log: Log) {
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
    
    public init?(for categories: [LogCategory] = LogCategory.all, with mode: Mode = .append, on filePath: String, formatter: LogFormatter = LogFormatter.default, delimitter: String = "\u{FFFF}\n", encoding: String.Encoding = .utf8) {
        self.allowedCategories = categories
        self.mode = mode
        self.encoding = encoding
        self.filePath = filePath
        
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
        case .wipe:
            self.storage.truncateFile(atOffset: 0)
        }
    }
    
    public func flush() {
        storage.synchronizeFile()
    }
    
    deinit {
        storage.synchronizeFile()
        storage.closeFile()
    }
}

extension LogFileStorage {
    
    public enum Mode {
        case append
        //    case cycle(logCount: UInt)
        case wipe
    }
}

extension LogFileStorage {
    
    public struct Reader : LogStorageReader {
        
        private let delimitter: Data
        private let encoding: String.Encoding
        
        private let bufferSize: Int = 512
        private var readBuffer: NSMutableData = NSMutableData(capacity: 512)!
        
        private let readHandle: FileHandle
        
        fileprivate init(of storage: LogFileStorage) {
            self.readHandle = FileHandle(forReadingAtPath: storage.filePath)!
            self.delimitter = storage.delimitter
            self.encoding = storage.encoding
        }
        
        public mutating func next() -> String? { // TODO: convert from string to log
            var range = readBuffer.range(of: delimitter, options: [], in: NSMakeRange(0, readBuffer.length))
            while range.location == NSNotFound {
                let tmpData = readHandle.readData(ofLength: bufferSize)
                if tmpData.count == 0 {
                    
                    if readBuffer.length > 0 {
                        let log = String(data: readBuffer as Data, encoding: encoding)
                        
                        readBuffer.length = 0
                        return log
                    }
                    return nil
                }
                readBuffer.append(tmpData)
                range = readBuffer.range(of: delimitter, options: [], in: NSMakeRange(0, readBuffer.length))
            }
            
            let log = String(data: readBuffer.subdata(with: NSMakeRange(0, range.location)),
                              encoding: encoding)
            readBuffer.replaceBytes(in: NSMakeRange(0, range.location + range.length), withBytes: nil, length: 0)
            
            return log
        }
        
        public mutating func rewind() {
            readHandle.seek(toFileOffset: 0)
        }
    }
}

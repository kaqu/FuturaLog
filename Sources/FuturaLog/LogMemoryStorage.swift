import Foundation

public final class LogMemoryStorage : LogReceiver {
    
    fileprivate let synchronizationQueue = DispatchQueue(label: "futura.log.storage.memory.syncQueue")
    
    public let allowedCategories: [LogCategory]
    
    private let capacity: UInt
    private var storage: [Log]
    
    public init(for categories: [LogCategory] = LogCategory.all, withCapacity capacity: UInt = 256) {
        self.allowedCategories = categories
        self.capacity = capacity
        self.storage = []
    }
    
    public func recieve(_ log: Log) {
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
    
    public func flush() {
        synchronizationQueue.sync { /* just wait */ }
    }
    
    public var reader: Reader {
        return Reader(of: self)
    }
}

extension LogMemoryStorage {
    
    public struct Reader : LogStorageReader {
        
        private weak var storage: LogMemoryStorage?
        private var index: Int = 0
        
        fileprivate init(of storage: LogMemoryStorage) {
            self.storage = storage
        }
        
        public mutating func next() -> Log? {
            guard let storage = storage else {
                return nil
            }
            return storage.synchronizationQueue.sync {
                if storage.storage.count > index {
                    return storage.storage[index]
                } else {
                    return nil
                }
            }
        }
        
        public mutating func rewind() {
            index = 0
        }
    }
}

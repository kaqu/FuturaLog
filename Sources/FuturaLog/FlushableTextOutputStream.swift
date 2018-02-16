import Foundation

public typealias FlushableTextOutputStream = TextOutputStream & FlushableOutputStream

public protocol FlushableOutputStream {
    func flush()
}

extension FileHandle : FlushableTextOutputStream {
    
    public func write(_ string: String) {
        guard let data = "\(string)\n".data(using: .utf8) else { return }
        self.write(data)
    }
    
    public func flush() {
        self.synchronizeFile()
    }
}

import Foundation

public final class LogPrinter : LogReceiver {

    public let allowedCategories: [LogCategory]
    
    private let synchronizationQueue = DispatchQueue(label: "futura.log.printer.syncQueue")
    private let formatter: LogFormatter
    private let output: (String)->()
    
    public init(for categories: [LogCategory] = LogCategory.all, with formatter: LogFormatter = LogFormatter.default, using output: @escaping (String)->() = { Swift.print($0) }) {
        self.allowedCategories = categories
        self.formatter = formatter
        self.output = output
    }
    
    public func recieve(_ log: Log) {
        synchronizationQueue.async {
            guard self.allowedCategories.contains(log.category) else {
                return
            }
            self.output("\(self.formatter.format(log))")
        }
    }
    
    public func flush() {
        synchronizationQueue.sync {
            FileHandle.standardOutput.synchronizeFile()
        }
    }
}

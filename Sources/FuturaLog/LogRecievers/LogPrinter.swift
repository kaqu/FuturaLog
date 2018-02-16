import Foundation

public final class LogPrinter : LogReceiver {

    public let allowedCategories: [LogCategory]
    
    private let formatter: LogFormatter
    private var output: FlushableTextOutputStream
    
    public init(for categories: [LogCategory] = LogCategory.all, with formatter: LogFormatter = LogFormatter.default, using output: FlushableTextOutputStream = FileHandle.standardOutput) {
        self.allowedCategories = categories
        self.formatter = formatter
        self.output = output
    }
    
    public func recieve(_ log: Log) {
        guard self.allowedCategories.contains(log.category) else { return }
        output.write("\(self.formatter.format(log))")
    }
    
    public func flush() {
        output.flush()
    }
}

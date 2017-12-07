import Foundation

public final class LogServer : LogReciver {
    
    public let allowedCategories: [LogCategory] = LogCategory.all
    
    private let logServerSession: URLSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
    
    private let synchronizationQueue = DispatchQueue(label: "futura.log.server.syncQueue")
    
    private var gatheredLogs: [Log] = []
    
    private let serverURL: URL
    
    private let applicationID: String
    private let environment: String
    private let sessionID: String = UUID().description
    
    private let mode: Mode
    
    init(at serverURL: URL, uploadMode mode: Mode = .continousUpload, applicationID: String, environment: String) {
        self.serverURL = serverURL
        self.mode = mode
        self.applicationID = applicationID
        self.environment = environment
    }
    
    public func recive(_ log: Log) {
        synchronizationQueue.async {
            guard self.allowedCategories.contains(log.category) else {
                return
            }
            switch self.mode {
            case .continousUpload:
                self.gatheredLogs.append(log)
            case let .uploadPackages(size):
                self.gatheredLogs.append(log)
                guard self.gatheredLogs.count >= size else {
                    return
                }
            case .uploadPeriodically:
                return
            }
            self.uploadLogs()
        }
    }
    
    private func uploadLogs() {
        var request = URLRequest(url: serverURL.appendingPathComponent("uploadLogs"))
        request.httpBody = try? JSONEncoder().encode(LogPackageDTO(applicationID: applicationID, sessionID: sessionID, environment: environment, logs: gatheredLogs))
        logServerSession.dataTask(with: request).resume()
        gatheredLogs = []
        // TODO: think about logging failure and retry
    }
    
    public func flush() {
        uploadLogs()
        // TODO: make request sync
    }
    
    public enum Mode {
        case continousUpload
        case uploadPackages(size: UInt)
        case uploadPeriodically(every: TimeInterval)
    }
}


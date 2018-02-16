import Foundation

public final class LogServer : LogReceiver {
    
    public static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        return encoder
    }()
    
    public let allowedCategories: [LogCategory] = LogCategory.all
    
    private let logServerSession: URLSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
    
    private let synchronizationQueue = DispatchQueue(label: "futura.log.server.syncQueue")
    
    private var logsBuffer: [Log] = []
    
    private let serverURL: URL
    
    private let applicationID: String
    private let environment: LogEnvironment
    private let accessToken: String
    
    private let mode: Mode
    
    public init(at serverURL: URL, accessToken: String, uploadMode mode: Mode = .continousUpload, applicationID: String, environment: LogEnvironment) {
        self.serverURL = serverURL
        self.accessToken = accessToken
        self.mode = mode
        self.applicationID = applicationID
        self.environment = environment
    }
    
    public func recieve(_ log: Log) {
        synchronizationQueue.async {
            guard self.allowedCategories.contains(log.category) else {
                return
            }
            switch self.mode {
            case .continousUpload:
                self.logsBuffer.append(log)
            case let .uploadPackages(size):
                self.logsBuffer.append(log)
                guard self.logsBuffer.count >= size else {
                    return
                }
//            case .uploadPeriodically:
//                return
            }
            self.uploadLogs()
        }
    }
    
    private func uploadLogs() {
        var request = URLRequest(url: serverURL.appendingPathComponent("uploadLogs"))
        request.httpBody = try? LogServer.jsonEncoder.encode(LogPackage(applicationID: applicationID, environment: environment, sessionID: Logger.sessionID, logs: logsBuffer))
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["Authorization":"Bearer \(accessToken)"]
        logServerSession.dataTask(with: request).resume()
        logsBuffer = []
        // TODO: think about logging failure and retry
    }
    
    public func flush() {
        uploadLogs()
        // TODO: make request sync
    }
    
    public enum Mode {
        case continousUpload
        case uploadPackages(size: UInt)
//        case uploadPeriodically(every: TimeInterval)
    }
}


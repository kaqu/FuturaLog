import Foundation

public protocol LogReceiver {
    
    var allowedCategories: [LogCategory] { get }
    
    func recieve(_ log: Log)
    func flush()
}

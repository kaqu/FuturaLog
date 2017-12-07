import Foundation

public protocol LogReciver {
    
    var allowedCategories: [LogCategory] { get }
    
    func recive(_ log: Log)
    func flush()
}


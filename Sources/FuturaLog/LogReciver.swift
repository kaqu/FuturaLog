import Foundation

public protocol LogReciver {
    
    var allowedCategories: [LogCategory] { get }
    func send(_ log: Log)
}


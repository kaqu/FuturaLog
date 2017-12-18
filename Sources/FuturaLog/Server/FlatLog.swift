//
//  FlatLog.swift
//  FuturaLog
//
//  Created by Kacper Kaliński on 18/12/2017.
//

import Foundation

public struct FlatLog : Codable {
    
    public let applicationID: String
    public let sessionID: String
    
    public let environmentName: String
    public let appVersion: String
    public let platform: String?
    public let osInfo: String?
    public let environmentInfo: String?

    public let category: LogCategory
    public let context: String?
    public let timestamp: Date
    public let message: String

    public init(applicationID: String, sessionID: String, environmentName: String, appVersion: String, platform: String?, osInfo: String?, environmentInfo: String?, category: LogCategory, context: String?, timestamp: Date, message: String) {
        self.applicationID = applicationID
        self.sessionID = sessionID
        self.environmentName = environmentName
        self.appVersion = appVersion
        self.platform = platform
        self.osInfo = osInfo
        self.environmentInfo = environmentInfo
        self.category = category
        self.context = context
        self.timestamp = timestamp
        self.message = message
    }
}

//
//  File.swift
//  
//
//  Created by Neil Smith on 26/08/2019.
//

import Foundation

public struct TimerNotification {
    
    let date: Date
    let identifier: NotificationIdentifier
    let content: TimerNotification.Content
    
    private let timer: TimeKeeper
    
    init?(sendAt date: Date, timer: TimeKeeper, content: TimerNotification.Content) {
        guard date > Date() else { return nil }
        guard let identifier = timer.notificationIdentifier else { return nil }
        self.date = date
        self.timer = timer
        self.identifier = identifier
        self.content = content
    }
    
    public struct Content {
        
        let title: String
        let body: String
        let badgeNumber: Int?
        let sound: Sound
        
        public init(title: String, body: String, badgeNumber: Int?, sound: Sound) {
            self.title = title
            self.body = body
            self.badgeNumber = badgeNumber
            self.sound = sound
        }
        
        public enum Sound: Int {
            case none = 0
            case notificationDefined
            case appDefined
            var value: NSNumber {
                return NSNumber(integerLiteral: self.rawValue)
            }
        }
    }
}

public extension TimerNotification {
    
    static func received(with identifier: String) {
        NotificationCenter.default.post(
            name: TimerNotification.didReceiveScheduledNotification,
            object: nil,
            userInfo: [TimerNotification.didReceiveUserInfoKey : identifier]
        )
    }
    
}

extension TimerNotification {
    
    static var didReceiveScheduledNotification: Notification.Name {
        return Notification.Name("com.NeilSmithDesignLTD.TimerController.didReceiveNotification")
    }
    
    static var didReceiveUserInfoKey: String {
        return "com.NeilSmithDesignLTD.TimerController.didReceive.notification.identifier"
    }
    
}

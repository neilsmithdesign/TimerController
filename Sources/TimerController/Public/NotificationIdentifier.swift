//
//  NotificationIdentifier.swift
//  
//
//  Created by Neil Smith on 26/08/2019.
//

import Foundation

public typealias NotificationIdentifier = String

extension TimeKeeper {
    
    var notificationIdentifier: NotificationIdentifier? {
        guard type == .countdown else { return nil }
        let expirationDate = Date().addingTimeInterval(currentTime)
        return expirationDate.description.replacingOccurrences(of: " ", with: ".")
    }
    
}

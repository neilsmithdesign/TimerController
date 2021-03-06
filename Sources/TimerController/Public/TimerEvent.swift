//
//  File.swift
//  
//
//  Created by Neil Smith on 09/03/2020.
//

import Foundation

public struct TimerEvent {
    public let id: TimerIdentifier
    public let kind: Kind
}

public extension TimerEvent {
    
    enum Kind {
        case updated(time: TimeInterval)
        case countdownEnded(whilstBackgrounded: Bool)
        case pausedOnInterruption
        case resumed
    }
    
}

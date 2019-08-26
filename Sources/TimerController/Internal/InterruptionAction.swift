//
//  InterruptionAction.swift
//  
//
//  Created by Neil Smith on 26/08/2019.
//

import UIKit

enum InterruptionAction {
    
    case pause
    case resume
    case scheduleTimerNotification
    case cancelTimerNotification
    
    init?(_ notification: Notification, timerType: TimerType, interruptionPolicy: InterruptionPolicy) {
        switch notification.name {
        case UIApplication.willResignActiveNotification,
             UIApplication.didEnterBackgroundNotification:
            switch interruptionPolicy {
            case .notifyOnExpiration:
                guard timerType == .countdown else { return nil }
                self = .scheduleTimerNotification
            case .pauseAutomatically, .pauseAndResumeAutomatically:
                self = .pause
            default:
                return nil
            }
        case UIApplication.willEnterForegroundNotification,
             UIApplication.didBecomeActiveNotification:
            switch interruptionPolicy {
            case .notifyOnExpiration:
                guard timerType == .countdown else { return nil }
                self = .cancelTimerNotification
            case .pauseAndResumeAutomatically:
                self = .resume
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
}

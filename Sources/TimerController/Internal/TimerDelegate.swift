//
//  TimerDelegate.swift
//  
//
//  Created by Neil Smith on 26/08/2019.
//

import Foundation

protocol TimerDelegate: AnyObject {
    func didPauseOnInterruption(_ timer: TimeKeeper)
    func didResumeAfterInterruption(_ timer: TimeKeeper)
    func scheduleUserNotification(toSendAt date: Date, timer: TimeKeeper)
    func cancelScheduledNotification(forTimerWith notificationIdentifier: NotificationIdentifier)
}

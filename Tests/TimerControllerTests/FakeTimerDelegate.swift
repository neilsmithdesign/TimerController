//
//  File.swift
//  
//
//  Created by Neil Smith on 26/08/2019.
//

import Foundation
@testable import TimerController

final class FakeTimerDelegate: TimerDelegate {
    
    init() {}
    
    var didPause: Bool = false
    var didResume: Bool = false
    var didSchedule: Bool = false
    var didCancel: Bool = false
    
    func didPauseOnInterruption(_ timer: TimeKeeper) {
        didPause = true
    }
    
    func didResumeAfterInterruption(_ timer: TimeKeeper) {
        didResume = true
    }
    
    func scheduleUserNotification(toSendAt date: Date, timer: TimeKeeper) {
        didSchedule = true
    }
    
    func cancelScheduledNotification(forTimerWith notificationIdentifier: NotificationIdentifier) {
        didCancel = true
    }
    
}

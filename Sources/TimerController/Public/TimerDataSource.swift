//
//  TimerDataSource.swift
//  
//
//  Created by Neil Smith on 26/08/2019.
//

import Foundation

public protocol TimerDataSource: AnyObject {
    func timerController(_ timerController: TimerController, notificationContentForTimerWith id: TimerIdentifier) -> TimerNotification.Content?
}

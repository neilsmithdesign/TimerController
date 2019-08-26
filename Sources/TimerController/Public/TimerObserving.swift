//
//  TimerObserving.swift
//  
//
//  Created by Neil Smith on 26/08/2019.
//

import Foundation

public protocol TimerObserving: AnyObject {
    func timerController(_ timerController: TimerController, timer id: TimerIdentifier, didUpdateWith time: TimeInterval)
    func timerController(_ timerController: TimerController, didEndCountdownTimerWith id: TimerIdentifier, whilstInTheBackground: Bool)
    func timerController(_ timerController: TimerController, didResetTimerWith id: TimerIdentifier)
    func timerController(_ timerController: TimerController, didPauseOnInterruptionTimerWith id: TimerIdentifier)
    func timerController(_ timerController: TimerController, didResume id: TimerIdentifier)
}

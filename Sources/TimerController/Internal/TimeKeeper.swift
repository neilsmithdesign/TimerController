//
//  TimeKeeper.swift
//  
//
//  Created by Neil Smith on 26/08/2019.
//

import UIKit

final class TimeKeeper {
    
        
    // MARK: Interface
    weak var delegate: TimerDelegate?
    
    init(_ type: TimerType,
         startingAt time: TimeInterval,
         interruptionPolicy: InterruptionPolicy
        ) {
        self.type = type
        let t: TimeInterval = type == .stopwatch ? -time : time
        self.notableDate = Date().addingTimeInterval(t)
        self.interruptionPolicy = interruptionPolicy
        setupSubscriptions()
    }
    
    
    /// Whether the timer is a stopwatch or countdown clock
    let type: TimerType
    
    
    /// The current time of the timer
    /// Considers all paused time periods to determine value
    var currentTime: TimeInterval {
        return calculated(currentTimeFor: self.type)
    }
    
    
    /// Convenience property for reading state
    var isRunning: Bool {
        return state == .running
    }
    
    var isValid: Bool {
        guard type == .countdown else { return true }
        return notableDate >= Date().addingTimeInterval(-0.1) // slight hack for handling foreground and background notifications
    }
    
    
    /// Toggles the timer to and from a paused / running state
    func toggleState() {
        switch state {
        case .paused: resume()
        case .running: pause()
        }
    }
    
    /// Pauses the timer and records the date at which it happened.
    /// Guards against incorrect state (e.g. will only execute in
    /// full if the timer is currently running)
    func pause() {
        guard state != .paused else { return }
        state = .paused
        pausedAt = Date()
    }
    
    /// Resumes the timer and caches the time that was spent in the paused state
    /// Guards against incorrect state (e.g. will only execute in
    /// full if the timer is currently paused)
    func resume() {
        guard state != .running else { return }
        state = .running
        cachePausedTimeIfNeeded()
    }
    
    
    // MARK: Private
    
    /// Defines the date which is used in calculations for either TimerType
    ///
    /// For stopwatch, this is the starting date. Whilst this is typically the
    /// start date (i.e. 'now') in most cases, it could be a date in the past
    /// if the stopwatch was to start at a value greater than a zero (TimeInterval).
    ///
    /// For countdown, this date signifies the date at which the timer will
    /// finish (and when the currentTime property would produce a value of zero).
    private let notableDate: Date
    
    
    /// A value which denotes when a timer can be considered 'finished'.
    private var endDate: Date {
        switch type {
        case .stopwatch: return .distantFuture
        case .countdown: return notableDate
        }
    }
    
    
    /// The current state of the timer. Either paused or running
    private (set) var state: TimerState = .running
    
    
    /// A cache of time periods for when the timer was in the paused state
    /// These are used in calculating the currentTime value
    private lazy var pausedTime = Set<TimeInterval>()
    
    
    /// A temporary cache of the date at which the timer's current paused state started
    private var pausedAt: Date?
    
    
    /// Describes how to handle interruptions (such as when the app enters/exits the foreground)
    private let interruptionPolicy: InterruptionPolicy
    
    
}


// MARK: - Calculations
extension TimeKeeper {
    
    
    /// Calculation for the current time based on time type
    /// - the difference in notable date and current date
    /// - the total paused time so far
    /// - the timer type
    private func calculated(currentTimeFor type: TimerType) -> TimeInterval {
        let delta = date(deltaFor: type)
        switch type {
        case .countdown: return delta + totalPausedTime
        case .stopwatch: return delta - totalPausedTime
        }
    }
    
    
    /// Ensures the highest date (the date most in the future)
    /// is used as the receiver for the calculation
    private func date(deltaFor type: TimerType) -> TimeInterval {
        switch type {
        case .countdown: return notableDate.timeIntervalSince(Date())
        case .stopwatch: return Date().timeIntervalSince(notableDate)
        }
    }
    
    
    var totalPausedTime: TimeInterval {
        return pausedTime.reduce(0, +)
    }
    
}

// MARK: - Caching
extension TimeKeeper {

    
    /// Caches the time interval for which the timer was just currently paused for
    private func cachePausedTimeIfNeeded() {
        guard let date = pausedAt else { return }
        let t = Date().timeIntervalSince(date)
        pausedTime.insert(t)
        pausedAt = nil
    }
    
}


// MARK: - Interruptions
extension TimeKeeper {
    
    
    private func setupSubscriptions() {
        let nc = NotificationCenter.default
        [
            UIApplication.willResignActiveNotification,
            UIApplication.didEnterBackgroundNotification,
            UIApplication.willEnterForegroundNotification,
            UIApplication.didBecomeActiveNotification
        ].forEach {
            nc.addObserver(
                self,
                selector: #selector(didReceive(_:)),
                name: $0,
                object: nil
            )
        }
    }
    
    @objc func didReceive(_ notification: Notification) {
        guard let action = InterruptionAction(
            notification,
            timerType: self.type,
            interruptionPolicy: interruptionPolicy) else { return }
        handle(notification: action)
    }
    
    private func handle(notification action: InterruptionAction) {
        switch action {
        case .pause:
            switch interruptionPolicy {
            case .pauseAndResumeAutomatically, .pauseAutomatically:
                pause()
                delegate?.didPauseOnInterruption(self)
            case .none, .notifyOnExpiration: break
            }
        case .resume:
            switch interruptionPolicy {
            case .pauseAndResumeAutomatically:
                resume()
                delegate?.didResumeAfterInterruption(self)
            case .none, .notifyOnExpiration, .pauseAutomatically: break
            }
        case .scheduleTimerNotification:
            let date = Date().addingTimeInterval(currentTime)
            delegate?.scheduleUserNotification(toSendAt: date, timer: self)
        case .cancelTimerNotification:
            if let id = self.notificationIdentifier {
                delegate?.cancelScheduledNotification(forTimerWith: id)
            }
        }
    }

    
}

extension TimeKeeper: Equatable {
    
    static func == (lhs: TimeKeeper, rhs: TimeKeeper) -> Bool {
        let l = ObjectIdentifier(lhs)
        let r = ObjectIdentifier(rhs)
        return l == r
    }
    
}

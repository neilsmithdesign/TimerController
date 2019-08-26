//
//  TimerController.swift
//  
//
//  Created by Neil Smith on 26/08/2019.
//

import Foundation

public final class TimerController {
    
    
    // MARK: Interface
    public init(_ tolerance: TimeInterval = 0.1) {
        timer = InternalTimer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(timerDidFire),
            userInfo: nil,
            repeats: true
        )
        timer?.tolerance = tolerance
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveScheduled(_:)),
            name: TimerNotification.didReceiveScheduledNotification,
            object: nil
        )
    }
    
    
    /// Observer for receiving updates about active timers
    public weak var observer: TimerObserving?
    
    
    /// Primarily for requesting content for local notifications
    public weak var dataSource: TimerDataSource?
    
    
    /// Starts a timer and returns it's assocaited ID
    public func create(_ type: TimerType,
                      startingAt time: TimeInterval,
                      interruptionPolicy: InterruptionPolicy) -> TimerIdentifier {
        let timer = TimeKeeper(
            type,
            startingAt: time,
            interruptionPolicy: interruptionPolicy
        )
        timer.delegate = self
        let id = TimerIdentifier(timer)
        activeTimers[id] = timer
        return id
    }
    
    
    /// Toggles the requested timer to either 'paused' or 'running'
    public func toggle(timerWith id: TimerIdentifier) {
        self.activeTimers[id]?.toggleState()
    }
    
    public func resume(timerWith id: TimerIdentifier) {
        self.activeTimers[id]?.resume()
    }
    
    public func pause(timerWith id: TimerIdentifier) {
        self.activeTimers[id]?.pause()
    }
    
    public func stop(timerWith id: TimerIdentifier) {
        self.activeTimers.removeValue(forKey: id)
    }
    
    /// Queries the active timers cache with the supplied id for it's current state
    /// Returns nil if the timer is no longer active (i.e. cached)
    public func state(forTimerWith id: TimerIdentifier) -> TimerState? {
        return activeTimers[id]?.state
    }
    
    @objc private func didReceiveScheduled(_ notification: Notification) {
        guard let notificationIdentifier = notification.userInfo?[TimerNotification.didReceiveUserInfoKey] as? String else { return }
        NotificationCache.remove(notificationFor: notificationIdentifier)
        guard let id = activeTimers.first(where: { $0.value.notificationIdentifier == notificationIdentifier })?.key else { return }
        activeTimers.removeValue(forKey: id)
        observer?.timerController(self, didEndCountdownTimerWith: id, whilstInTheBackground: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.notificationController.removeDelivered(notificationWith: notificationIdentifier)
        }
    }

    // MARK: Private
    
    /// Internal cache of all currently active timers
    private var activeTimers: [TimerIdentifier : TimeKeeper] = [:]
    
    
    /// The acutal (Foundation framework) Timer responsible for callbacks to the observer
    private var timer: InternalTimer?
    
    
    /// Schedules and cancels notifications (if authorized) when the app moves to/from the background
    private lazy var notificationController: NotificationController = .init()
    
    
    /// Notifies the observer with the current time for all active timers
    /// that are in the 'running' state. Checks whether a timer is complete
    /// The timer is checked for validity
    @objc private func timerDidFire() {
        for (id, timer) in activeTimers {
            guard timer.isRunning else { continue }
            let didEnd = removeIfNeeded(timer, with: id)
            if didEnd {
                let whilstInTheBackground = !timer.isValid
                observer?.timerController(self, didEndCountdownTimerWith: id, whilstInTheBackground: whilstInTheBackground)
            } else {
                observer?.timerController(self, timer: id, didUpdateWith: timer.currentTime)
            }
        }
    }
    
    
    /// Removes countdown timers when they reach a current time value of zero
    private func removeIfNeeded(_ timer: TimeKeeper, with id: TimerIdentifier) -> Bool {
        guard timer.currentTime < 0 && timer.type == .countdown else { return false }
        self.activeTimers.removeValue(forKey: id)
        return true
    }
    
    
    // MARK: Deinit
    deinit {
        self.timer?.invalidate()
        self.timer = nil
    }
    
}


// MARK: Timer delegate
extension TimerController: TimerDelegate {
    
    
    // MARK: Interruptions
    func didPauseOnInterruption(_ timer: TimeKeeper) {
        let id = TimerIdentifier(timer)
        observer?.timerController(self, didPauseOnInterruptionTimerWith: id)
    }
    
    func didResumeAfterInterruption(_ timer: TimeKeeper) {
        let id = TimerIdentifier(timer)
        observer?.timerController(self, didResume: id)
    }
    
    
    // MARK: Notifications
    /// Validates whether a notification should be scheduled before doing so
    /// Caches the notification by it's identifier
    func scheduleUserNotification(toSendAt date: Date, timer: TimeKeeper) {
        guard let notification = self.notification(toSendAt: date, timer: timer) else { return }
        guard !NotificationCache.contains(timerNotificationFor: notification.identifier) else { return } // ensures there isn't a notification currently scheduled
        notificationController.scheduleIfAuthorized(notification) { identifier in
            guard let id = identifier else { return }
            NotificationCache.add(notification, identifier: id)
        }
    }
    
    /// Cancels the notification with the notification controller and removes from local cache
    func cancelScheduledNotification(forTimerWith notificationIdentifier: NotificationIdentifier) {
        notificationController.cancel(notificationWith: notificationIdentifier)
        NotificationCache.remove(notificationFor: notificationIdentifier)
    }
    
    
    /// Helper
    private func notification(toSendAt date: Date, timer: TimeKeeper) -> TimerNotification? {
        guard let id = activeTimers.first(where: { $0.value == timer  })?.key else { return nil }
        guard let content = dataSource?.timerController(self, notificationContentForTimerWith: id) else { return nil }
        return TimerNotification(sendAt: date, timer: timer, content: content)
    }
    
}

public extension TimerController {
    
    enum NotificationResult {
        case none
        case isExpiredTimer
    }

    struct NotificationCache {

        static func contains(timerNotificationFor identifier: NotificationIdentifier) -> Bool {
            return UserDefaults.standard.value(forKey: identifier) != nil
        }
        
        static func add(_ notification: TimerNotification, identifier: NotificationIdentifier) {
            UserDefaults.standard.set(notification.date, forKey: identifier)
        }
        
        static func remove(notificationFor identifier: NotificationIdentifier) {
            UserDefaults.standard.removeObject(forKey: identifier)
        }
        
    }
}

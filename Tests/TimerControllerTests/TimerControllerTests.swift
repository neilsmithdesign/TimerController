import XCTest
@testable import TimerController

final class TimerControllerTests: XCTestCase {
    
        // MARK: State
    func testTimerIsInitiallyRunning() {
        let timer = make(timerWith: .none)
        XCTAssert(timer.state == .running)
    }
    
    func testTimerTogglesStateOnToggle() {
        let timer = make(timerWith: .pauseAutomatically)
        XCTAssert(timer.state == .running)
        timer.toggleState()
        XCTAssert(timer.state == .paused)
        timer.toggleState()
        XCTAssert(timer.state == .running)
        timer.toggleState()
        XCTAssert(timer.state == .paused)
    }
    
    
    // MARK: Notification
    func testTimerRespondsToUIApplicationEventNotificationForPausing() {
        
        // Given
        let timer = make(timerWith: .pauseAutomatically)
        let delegate = FakeTimerDelegate()
        timer.delegate = delegate
        
        let onExit = UIApplication.willResignActiveNotification
        let nc = NotificationCenter.default
        
        timer.delegate = delegate
        
        // When
        nc.post(name: onExit, object: nil)
        
        // Then
        XCTAssert(timer.state == .paused)
        XCTAssert(delegate.didPause)
    }
    
    func testTimerRespondsToUIApplicationEventNotificationForResuming() {
        
        // Given
        let timer = make(timerWith: .pauseAndResumeAutomatically)
        let delegate = FakeTimerDelegate()
        timer.delegate = delegate
        let onExit = UIApplication.willResignActiveNotification
        let onEntry = UIApplication.didBecomeActiveNotification
        let nc = NotificationCenter.default

        // When
        nc.post(name: onExit, object: nil)
        nc.post(name: onEntry, object: nil)

        // Then
        XCTAssert(timer.state == .running)
        XCTAssert(delegate.didResume)

    }
    
    func testTimerRespondsToUIApplicationEventNotificationWithoutAutomaticResuming() {
        
        // Given
        let timer = make(timerWith: .pauseAutomatically)
        let delegate = FakeTimerDelegate()
        timer.delegate = delegate
        let onExit = UIApplication.willResignActiveNotification
        let onEntry = UIApplication.didBecomeActiveNotification
        let nc = NotificationCenter.default
        
        // When
        nc.post(name: onExit, object: nil)
        nc.post(name: onEntry, object: nil)
        
        // Then
        XCTAssert(timer.state == .paused)
        XCTAssert(!delegate.didResume)
        
    }
    
    
    // MARK: Performance
    func testTimerCurrentTimeCalculationPerformance() {
        let timer = make(timerWith: .none)
        self.measure {
            let _ = timer.currentTime
        }
    }

}

extension TimerControllerTests {
    
    private func make(timerWith interruptionPolicy: InterruptionPolicy, type: TimerType = .stopwatch, startingAt time: TimeInterval = 0) -> TimeKeeper {
        return TimeKeeper(
            type,
            startingAt: time,
            interruptionPolicy: interruptionPolicy
        )
    }
    
}

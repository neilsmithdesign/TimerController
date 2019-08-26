//
//  NotificationController.swift
//  
//
//  Created by Neil Smith on 26/08/2019.
//

import Foundation
import UserNotifications

final class NotificationController {
    
    init() {

    }
    
    class func currentAuthorization(_ completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized: completion(true)
                case .denied, .provisional, .notDetermined: completion(false)
                @unknown default:
                    fatalError()
                }
            }
        }
    }
    
    func scheduleIfAuthorized(_ notificaiton: TimerNotification, completion: @escaping (NotificationIdentifier?) -> Void) {
        NotificationController.currentAuthorization { isAuthorzied in
            guard isAuthorzied else { return }
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                guard !requests.contains(where: { $0.identifier == notificaiton.identifier }) else { return }
                UNUserNotificationCenter.current().add(notificaiton.notificationRequest, withCompletionHandler: { error in
                    DispatchQueue.main.async {
                        if let err = error {
                            print(err.localizedDescription)
                            completion(nil)
                            return
                        }
                        completion(notificaiton.identifier)
                    }
                })
            }
        }
    }
    
    func cancel(notificationWith identifier: NotificationIdentifier) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    @objc private func didReceiveScheduled(_ notification: Notification) {
        guard let id = notification.userInfo?[TimerNotification.didReceiveUserInfoKey] as? String else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.removeDelivered(notificationWith: id)
        }
    }
    
    func removeDelivered(notificationWith identifier: NotificationIdentifier) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
    }
    
    
}


// MARK: Computed UserNotification request, content and trigger
private extension TimerNotification {
    
    var notificationRequest: UNNotificationRequest {
        return .init(
            identifier: self.identifier,
            content: self.notificationContent,
            trigger: self.notificationTrigger
        )
    }

    private var notificationContent: UNNotificationContent {
        let nc = UNMutableNotificationContent()
        nc.title = content.title
        nc.body = content.body
        if let number = content.badgeNumber {
            nc.badge = NSNumber(value: number)
        }
        nc.sound = .default
        return nc
    }
    
    
    private var notificationTrigger: UNTimeIntervalNotificationTrigger {
        let time = date.timeIntervalSince(Date())
        return .init(
            timeInterval: time,
            repeats: false
        )
    }
    
}


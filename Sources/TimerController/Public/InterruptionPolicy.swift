//
//  InterruptionPolicy.swift
//  
//
//  Created by Neil Smith on 26/08/2019.
//

import Foundation

public enum InterruptionPolicy {
    case none // keeps timer running and expires silently
    case notifyOnExpiration // keeps timer running and sends local notification to user if permitted
    case pauseAutomatically // pauses when the app is interrupted
    case pauseAndResumeAutomatically
}

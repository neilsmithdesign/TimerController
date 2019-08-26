//
//  TimerIdentifier.swift
//  
//
//  Created by Neil Smith on 26/08/2019.
//

import Foundation

/// Returned by TimerController when creating a new Timer
/// Users are expected to retain this identifier for the
/// purpose of identifying and querying specific Timer instances
public typealias TimerIdentifier = ObjectIdentifier

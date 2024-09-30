//
//  PollingService.swift
//  Swap Money
//
//  Created by Akashlal Bathe on 30/09/24.
//

import Foundation

public protocol Pollable {
    init(pollingInterval: TimeInterval)
    func startPolling(callback: @escaping () -> Void)
    func stopPolling()
    func isPolling() -> Bool
    
}

class PollingService: Pollable {
    private var timer: Timer?
    private var interval: TimeInterval
    private var callback: (() -> Void)?
    
    required init(pollingInterval: TimeInterval) {
        self.interval = pollingInterval
    }
    
    // Start polling
    func startPolling(callback: @escaping () -> Void) {
        self.callback = callback
        stopPolling() // Stop any existing polling before starting new one

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.callback?() // Call the callback
        }
    }
    
    // Stop polling
    func stopPolling() {
        timer?.invalidate()
        timer = nil
    }
    
    // Check if polling is active
    func isPolling() -> Bool {
        return timer != nil
    }
    
    deinit {
        stopPolling() // Ensure the timer is stopped when the service is deallocated
    }
}

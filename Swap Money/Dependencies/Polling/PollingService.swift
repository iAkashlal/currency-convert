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
    private var callbackCallCount: Int = 0
    
    required init(pollingInterval: TimeInterval) {
        self.interval = pollingInterval
    }
    
    // Start polling
    func startPolling(callback: @escaping () -> Void) {
        self.callback = callback
        stopPolling() // Stop any existing polling before starting new one

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Logger.sharedInstance.log(key: "CallbackCalled", message: "Callback called \(String(describing: self?.callbackCallCount)) times", logLevel: .info)
            guard let self = self else { 
                Logger.sharedInstance.log(message: "Self nil \(#file) \(#line)")
                return
            }
            self.callbackCallCount += 1
            self.callback?() // Call the callback
            Logger.sharedInstance.log(message: "Callback called \(self.callbackCallCount) times")
        }
    }
    
    // Stop polling
    func stopPolling() {
        Logger.sharedInstance.log(message: "Stopped polling")
        timer?.invalidate()
        timer = nil
        self.callbackCallCount = 0
    }
    
    // Check if polling is active
    func isPolling() -> Bool {
        return timer != nil
    }
    
    deinit {
        stopPolling() // Ensure the timer is stopped when the service is deallocated
    }
}

//
//  PollingServiceTests.swift
//  Swap MoneyTests
//
//  Created by Akashlal Bathe on 03/10/24.
//

import XCTest
@testable import Swap_Money

final class PollingServiceTests: XCTestCase {

    func testPollingService_givenPollingIntervalOfOne_startPolling_shouldStartPollingAndInvokeCallbackThreeTimesInThreeSeconds() {
        // Given
        let pollingInterval: TimeInterval = 1.0
        let pollingService = PollingService(pollingInterval: pollingInterval)
        let expectation = self.expectation(description: "Callback invoked")
        var callbackInvokeCount = 0

        // When
        pollingService.startPolling {
            callbackInvokeCount += 1
            if callbackInvokeCount == 3 { // Expect callback to be called 3 times
                expectation.fulfill()
            }
        }

        // Then
        waitForExpectations(timeout: 3.0) { error in
            XCTAssertNil(error, "Callback should be invoked multiple times.")
            XCTAssertTrue(pollingService.isPolling(), "Polling should be active.")
        }
        pollingService.stopPolling()
    }

    func testPollingService_startPollingWithIntervalOneSecondAndStopPollingImmediately_shouldStopPollingAndNotCallbackEvenOnce() {
        // Given
        let pollingInterval: TimeInterval = 1.0
        let pollingService = PollingService(pollingInterval: pollingInterval)
        let expectation = self.expectation(description: "Polling stopped")
        var callbackInvokeCount = 0

        // When
        pollingService.startPolling {
            callbackInvokeCount += 1
        }
        pollingService.stopPolling()

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            XCTAssertFalse(pollingService.isPolling(), "Polling should be inactive.")
            XCTAssertEqual(callbackInvokeCount, 0, "Callback should not be invoked after polling stops.")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 3.0)
    }

    func testPollingService_givenMultipleStopPollingCalls_stopPolling_shouldNotThrowErrors() {
        // Given
        let pollingService = PollingService(pollingInterval: 1.0)

        // When
        pollingService.startPolling {}
        pollingService.stopPolling()
        pollingService.stopPolling()

        // Then
        XCTAssertFalse(pollingService.isPolling(), "Polling should be inactive after multiple stopPolling calls.")
    }

    func testPollingService_stoppARunningPollingService_startPollingAgain_shouldRestartPolling() {
        // Given
        let pollingInterval: TimeInterval = 1.0
        let pollingService = PollingService(pollingInterval: pollingInterval)
        let expectation = self.expectation(description: "Callback invoked after restart")
        var callbackInvokeCount = 0

        // When
        pollingService.startPolling {
            callbackInvokeCount += 1
        }
        pollingService.stopPolling()

        pollingService.startPolling {
            callbackInvokeCount += 1
            if callbackInvokeCount == 3 {
                expectation.fulfill()
            }
        }

        // Then
        waitForExpectations(timeout: 5.0) { error in
            XCTAssertNil(error, "Callback should be invoked after polling restarts.")
            XCTAssertTrue(pollingService.isPolling(), "Polling should be active after restart.")
        }
        pollingService.stopPolling()
    }

    func testPollingService_givenPollingServiceDeinit_shouldStopPollingAndRemovedFromMemory() {
        // Given
        var pollingService: PollingService? = PollingService(pollingInterval: 1.0)
        let expectation = self.expectation(description: "Polling service deallocated")
        
        // When
        pollingService?.startPolling {
            XCTFail("Callback should not be invoked after deinit")
        }
        pollingService?.stopPolling()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            pollingService = nil
            XCTAssertNil(pollingService, "Polling service should be deallocated.")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 3.0)
    }
}

//
//  ExchangeRateSDKTests.swift
//  Swap MoneyTests
//
//  Created by Akashlal Bathe on 03/10/24.
//

import XCTest
@testable import Swap_Money

// MARK: - Mock Classes

class MockExchangeRateSDKDelegate: ExchangeRateSDKDelegate {
    var isUpdatedCalledAtLeastOnce = false
    var updateCalledCount = 0
    
    func updatedRatesAvailable() {
        isUpdatedCalledAtLeastOnce = true
        updateCalledCount += 1
    }
}

class MockNetworkService: NetworkService<OERResponse> {
    var mockResponse: OERResponse?
    
    override func fetch(request: URLRequest) async throws -> (OERResponse, URLResponse) {
        if let response = mockResponse {
            return (response, URLResponse())
        } else {
            throw NSError(domain: "MockError", code: 404, userInfo: nil)
        }
    }
}

class MockPersistenceService<T: Codable>: LocalPersistence {
    var mockResponse: T?
    
    func saveState(_ response: T) {
        self.mockResponse = response
    }
    
    func restoreState() -> T? {
        return mockResponse
    }
    
    func clearState() {
        self.mockResponse = nil
    }
}

// MARK: - Tests

final class ExchangeRateSDKTests: XCTestCase {
    
    var mockDelegate: MockExchangeRateSDKDelegate!
    var mockNetworkService: MockNetworkService!
    var mockPersistenceService: AnyLocalPersistence<OERResponse>!
    var exchangeRateSDK: ExchangeRateSDK!
    
    override func setUp() {
        super.setUp()
        mockDelegate = MockExchangeRateSDKDelegate()
        mockNetworkService = MockNetworkService()
        mockPersistenceService = AnyLocalPersistence(MockPersistenceService<OERResponse>())
        exchangeRateSDK = ExchangeRateSDK(vendor: .openExchangeRates)
        exchangeRateSDK.updateNetworkService(with: mockNetworkService)
        exchangeRateSDK.updatePersistenceService(with: mockPersistenceService)
        mockPersistenceService.clearState()
        exchangeRateSDK.delegate = mockDelegate
    }
    
    override func tearDown() {
        mockDelegate = nil
        mockNetworkService = nil
        mockPersistenceService = nil
        exchangeRateSDK = nil
        Logger.sharedInstance.clearLogs()
        super.tearDown()
    }
    
    func test_localDataUptoDate_convertValidCurrency_returnsCorrectValue() {
        // Given
        let timeStamp = Int(Date().timeIntervalSince1970)
        let response = OERResponse(timestamp: (timeStamp),
                                               base: "USD",
                                   rates: ["USD": 1.0, "JPY": 100]
        )
        mockPersistenceService.saveState(response)
        exchangeRateSDK.loadData()
        
        // When
        let result = exchangeRateSDK.convert(from: "USD", to: "JPY", value: 0.1)
        
        // Then
        XCTAssertEqual(result, 10, "Conversion from USD to JPY should return the correct value from local persistence because it's not outdated.")
    }
    
    func test_localDataUptoDate_convertInvalidCurrency_returnsZeroAndLogsError() {
        // Given
        let timeStamp = Int(Date().timeIntervalSince1970)
        let response = OERResponse(timestamp: (timeStamp),
                                               base: "USD",
                                   rates: ["USD": 1.0, "JPY": 100]
        )
        mockPersistenceService.saveState(response)
        exchangeRateSDK.loadData()
        
        // When
        let result = exchangeRateSDK.convert(from: "USD", to: "EUR", value: 1)
        
        // Then
        XCTAssertEqual(result, 0, "Conversion from USD to EUR should return 0 because conversion rate is not available and this conversion should never have been performed.")
        XCTAssertTrue(
            Logger.sharedInstance.isLogged(partOfMessage: "rate is unavailable"),
            "Error that rate is unavailable should have been logged."
        )
        
    }
    
    func test_localDataUptoDate_monitorNetworkLogs_networkCallShouldNotHappen() {
        // Given
        let timeStamp = Int(Date().timeIntervalSince1970)
        let response10SecondsAgo = OERResponse(timestamp: (timeStamp - 10),
                                               base: "USD",
                                               rates: ["USD": 1.0, "EUR": 0.85]
        )
        
        mockPersistenceService.saveState(response10SecondsAgo)
        let responseLatest = OERResponse(timestamp: timeStamp,
                                               base: "USD",
                                         rates: ["USD": 1.0, "EUR": 0.90]
        )
        mockNetworkService.mockResponse = responseLatest
        exchangeRateSDK.updatePollingDuration(in: 300)
        exchangeRateSDK.loadData()
        
        // When
        let result = exchangeRateSDK.convert(from: "USD", to: "EUR", value: 100.0)
        
        // Then
        XCTAssertEqual(
            Logger.sharedInstance.isLogged(
                partOfMessage: "Local data outdated, attempting to fetch from network"
            ),
            false,
            "Local data is not outdated, network call should not happen"
        )
    }
    
    func test_firstTimeLoadLocalDataUnavailable_attemptToLoadFromNetwork_networkCallShouldHappen() {
        // Given
        let timeStamp = Int(Date().timeIntervalSince1970)
        mockPersistenceService.clearState()
        let responseLatest = OERResponse(timestamp: timeStamp,
                                               base: "USD",
                                         rates: ["USD": 1.0, "EUR": 0.90]
        )
        mockNetworkService.mockResponse = responseLatest
        
        // When
        exchangeRateSDK.updatePollingDuration(in: 50)
        exchangeRateSDK.loadData()
        let expectation = expectation(description: "Network call should happen")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            // Then
            XCTAssertTrue(
                Logger.sharedInstance.isLogged(partOfMessage: "Local data outdated, attempting to fetch from network"),
                "Local data outdated, network request should have occured"
            )
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)
    }

    func test_localDataPresent_validConversion_shouldReturnCorrectValueFromLocal() {
        // Given
        let timeStamp = Int(Date().timeIntervalSince1970)
        let response10SecondsAgo = OERResponse(timestamp: (timeStamp - 10),
                                               base: "USD",
                                               rates: ["USD": 1.0, "EUR": 0.85]
        )
        
        mockPersistenceService.saveState(response10SecondsAgo)
        let responseLatest = OERResponse(timestamp: timeStamp,
                                               base: "USD",
                                         rates: ["USD": 1.0, "EUR": 0.90]
        )
        mockNetworkService.mockResponse = responseLatest
        exchangeRateSDK.updatePollingDuration(in: 30)
        exchangeRateSDK.loadData()
        
        // When
        let result = exchangeRateSDK.convert(from: "USD", to: "EUR", value: 100.0)
        
        // Then
        XCTAssertEqual(result, 85.0, "Conversion from USD to EUR should return the correct value from local persistence because it's not outdated.")
    }
    
    func test_localDataOutdated_attemptToLoadFromNetwork_networkCallShouldHappen() {
        // Given
        let timeStamp = Int(Date().timeIntervalSince1970)
        let response100SecondsAgo = OERResponse(timestamp: (timeStamp - 100),
                                               base: "USD",
                                               rates: ["USD": 1.0, "EUR": 0.85]
        )
        mockPersistenceService.saveState(response100SecondsAgo)
        let responseLatest = OERResponse(timestamp: timeStamp,
                                               base: "USD",
                                         rates: ["USD": 1.0, "EUR": 0.90]
        )
        mockNetworkService.mockResponse = responseLatest
        
        // When
        exchangeRateSDK.updatePollingDuration(in: 50)
        exchangeRateSDK.loadData()
        let expectation = expectation(description: "Network call should happen")
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            // Then
            XCTAssertTrue(
                Logger.sharedInstance.isLogged(partOfMessage: "Local data outdated, attempting to fetch from network"),
                "Local data outdated, network request should have occured"
            )
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)
    }
    
    func test_localDataOutdated_validConversion_returnUpdatedConversionRates() {
        // Given
        let timeStamp = Int(Date().timeIntervalSince1970)
        let response10SecondsAgo = OERResponse(timestamp: (timeStamp - 100),
                                               base: "USD",
                                               rates: ["USD": 1.0, "EUR": 0.85]
        )
        mockPersistenceService.saveState(response10SecondsAgo)
        let responseLatest = OERResponse(timestamp: timeStamp,
                                               base: "USD",
                                         rates: ["USD": 1.0, "EUR": 0.90]
        )
        mockNetworkService.mockResponse = responseLatest
        exchangeRateSDK.updatePollingDuration(in: 4)
        exchangeRateSDK.loadData()
        let expectation = expectation(description: "Network call should happen")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // When
            let result = self.exchangeRateSDK.convert(from: "USD", to: "EUR", value: 100.0)
            // Then
            XCTAssertEqual(result, 90.0, "Conversion from USD to EUR should return the correct value.")
            expectation.fulfill()
            
        }
        waitForExpectations(timeout: 3.0)
    }
    
    func test_pollingDurationOneSecond_networkCallMadeFiveTimesOverFiveSeconds() {
        // Given
        let timeStamp = Int(Date().timeIntervalSince1970)
        let response100SecondsAgo = OERResponse(timestamp: (timeStamp - 100),
                                               base: "USD",
                                               rates: ["USD": 1.0, "EUR": 0.85]
        )
        mockPersistenceService.saveState(response100SecondsAgo)
        let responseLatest = OERResponse(timestamp: timeStamp,
                                               base: "USD",
                                         rates: ["USD": 1.0, "EUR": 0.90]
        )
        mockNetworkService.mockResponse = responseLatest
        
        // When
        exchangeRateSDK.updatePollingDuration(in: 1)
        exchangeRateSDK.loadData()
        let expectation = expectation(description: "Network call should happen 5 times")
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // Then
            XCTAssertTrue(
                Logger.sharedInstance.isLogged(partOfMessage: "Callback called 5 times"), "Data refresh is set to once every second, network request will callback 5 times")
            
            expectation.fulfill()
            
        }
        waitForExpectations(timeout: 6)
    }
    
    func test_pollingDurationOneSecond_callbackCalledOnlyTwiceBecauseRatesDontChange() {
        // Given
        let timeStamp = Int(Date().timeIntervalSince1970)
        let response100SecondsAgo = OERResponse(timestamp: (timeStamp - 100),
                                               base: "USD",
                                               rates: ["USD": 1.0, "EUR": 0.85]
        )
        mockPersistenceService.saveState(response100SecondsAgo)
        let responseLatest = OERResponse(timestamp: timeStamp,
                                               base: "USD",
                                         rates: ["USD": 1.0, "EUR": 0.90]
        )
        mockNetworkService.mockResponse = responseLatest
        
        // When
        exchangeRateSDK.updatePollingDuration(in: 1)
        exchangeRateSDK.loadData()
        let expectation = expectation(description: "Response didn't change as many times, delegate should be only notified twice")
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            
            // Then
            XCTAssertTrue(self.mockDelegate.updateCalledCount == 2, "Mock Network response doesn't change, so callback won't be called as many times")
            
            if self.mockDelegate.updateCalledCount == 2 {
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 7)
    }

    func test_pollingDurationOneSecond_pollingDurationUpdatedAfter5SecondsTo2Seconds_NetworkCallMade7TimesOver9Seconds() {
        // Given
        let timeStamp = Int(Date().timeIntervalSince1970)
        let responseLatest = OERResponse(timestamp: timeStamp,
                                               base: "USD",
                                         rates: ["USD": 1.0, "EUR": 0.90]
        )
        mockNetworkService.mockResponse = responseLatest
        
        // When
        exchangeRateSDK.updatePollingDuration(in: 1)
        exchangeRateSDK.loadData()
        let expectation = expectation(description: "Polling duration should be updatable in runtime")
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            // Then
            XCTAssertTrue(
                Logger.sharedInstance.isLogged(partOfMessage: "Callback called 7 times"), "Data refresh is set to once every second for first 5 seconds, then once every two seconds. So network request will callback 7 times in 10 seconds")
            expectation.fulfill()
            
        }
        waitForExpectations(timeout: 11)
    }
}


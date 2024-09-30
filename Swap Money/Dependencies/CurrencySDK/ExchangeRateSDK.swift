//
//  ExchangeRateSDK.swift
//  Swap Money
//
//  Created by Akashlal Bathe on 29/09/24.
//

import Foundation

enum CurrencySDKVendors {
    case openExchangeRates
}

public protocol ExchangeRateSDKDelegate {
    /// Get notified whenever new rates are available
    func updatedRatesAvailable()
}

public protocol ExchangeRateService {
    
    var delegate: ExchangeRateSDKDelegate? { get set }
    
    func convert(from: String, to: String, value: Double) -> Double
    func currenciesAvailableCount() -> Int
    func currenciesAvailable() -> [String]
}

final class ExchangeRateSDK: ExchangeRateService {
    var delegate: (any ExchangeRateSDKDelegate)?
    
    private var service: NetworkService<OERResponse>?
    private var persistenceService: LocalPersistence = FilePersistence()
    private var vendor: CurrencySDKVendors
    private var lastUpdatedEpoch: Int = 0
    
    private var currencies: [String] = []
    private var rates: [String: Double] = [:] {
        didSet {
            if rates != oldValue {
                updateCurrenciesAvailable()
            }
        }
    }
    
    private var pollingInSeconds = 1799
    private var pollingService: Pollable
        
    init(vendor: CurrencySDKVendors) {
        self.vendor = vendor
        self.pollingService = PollingService(pollingInterval: TimeInterval(pollingInSeconds))
        setupServices()
    }
    
    func updatePersistenceService(with service: LocalPersistence) {
        self.persistenceService = service
    }
    
    private func setupServices() {
        switch self.vendor {
        case .openExchangeRates:
            self.service = OERService()
        }
        
        self.updatePollingDuration(in: 1799)    // Setup default polling duration as 1799 ie. 29 minutes 59 seconds
    }
    
    /// Override default polling duration
    func updatePollingDuration(in seconds: Int) {
        self.pollingInSeconds = seconds
        self.pollingService.stopPolling()
        self.pollingService = PollingService(pollingInterval: TimeInterval(pollingInSeconds))
        self.pollingService.startPolling { [unowned self] in
            Task {
                await self.loadDataFromRemote()
            }
        }
    }
    
    func loadDataLocally() {
        // Load data from local cache
        if let response = persistenceService.restoreState() {
            self.lastUpdatedEpoch = response.timestamp
            self.rates = response.rates
            checkIfDataNeedsToBeLoaded()
        } else {
            Task {
                await loadDataFromRemote()
            }
        }
    }
    
    func checkIfDataNeedsToBeLoaded() {
        let currentEpoch = Int(Date().timeIntervalSince1970)
        let timeDifference = currentEpoch - lastUpdatedEpoch
        
        // Check if the difference is greater than set polling duration
        if timeDifference > pollingInSeconds {
            Task {
                await loadDataFromRemote()
            }
        }
    }

    
    // Load data from service, meant to be called once every 30 minutes
    func loadDataFromRemote() async {
        do {
            let output = try await service?.fetch(request: OpenExchangeRateAPI.latest.request!)
            if let (response, urlResponse) = output {
                self.lastUpdatedEpoch = Int(Date().timeIntervalSince1970)
                self.rates = response.rates
                saveDataLocally(response: response)
            }
        } catch {
            debugPrint(error)
        }
    }
    
    func saveDataLocally(response: OERResponse) {
        // Save data to local store so that cache can be used on next open
        let timeStampOverriddenResponse = OERResponse(
            timestamp: Int(Date().timeIntervalSince1970),
            base: response.base,
            rates: response.rates
        )
        persistenceService.saveState(response)
    }
    
    func updateCurrenciesAvailable() {
        defer {
            notifyObserverAboutUpdatedRates()
        }
        var newCurrencies = [String]()
        self.rates.forEach { currency, _ in
            newCurrencies.append(currency)
        }
        newCurrencies.sort()
        if self.currencies != newCurrencies {
            self.currencies = newCurrencies
            
        }
    }
    
    func notifyObserverAboutUpdatedRates() {
        guard let delegate else {
            Logger.sharedInstance.log(message: "Delegate to observe changes not available")
            return
        }
        delegate.updatedRatesAvailable()
    }
    
    func convert(from: String, to: String, value: Double) -> Double {
        let usdEquivalent = convertToUSD(from: from, value: value)
        return convertFromUSD(to: to, value: usdEquivalent)
    }
    
    func currenciesAvailable() -> [String] {
        return self.currencies
    }
    
    func currenciesAvailableCount() -> Int {
        return self.currencies.count
    }
    
    deinit {
        self.pollingService.stopPolling()
    }
    
}

private extension ExchangeRateSDK {
    func convertToUSD(from currency: String, value: Double) -> Double {
        guard let rate = rates[currency] else {
            Logger.sharedInstance.log(message: "Invalid Currency code. Tried to convert from \(currency) whose rate is unavailable")
            return 0.0
        }
        return value / rate
    }

    func convertFromUSD(to currency: String, value: Double) -> Double {
        guard let rate = rates[currency] else {
            Logger.sharedInstance.log(message: "Invalid Currency code. Tried to convert to \(currency) whose rate is unavailable")
            return 0.0
        }
        return value * rate
    }
    
    
}

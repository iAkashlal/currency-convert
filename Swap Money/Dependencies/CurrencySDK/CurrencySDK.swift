//
//  CurrencySDK.swift
//  Swap Money
//
//  Created by Akashlal Bathe on 29/09/24.
//

import Foundation

enum CurrencySDKVendors {
    case openExchangeRates
}

public protocol CurrencySDKDelegate {
    /// Get notified whenever new rates are available
    func updatedRatesAvailable()
}

public protocol CurrencyService {
    
    var delegate: CurrencySDKDelegate? { get set }
    
    func convert(from: String, to: String, value: Double) -> Double
    func currenciesAvailableCount() -> Int
    func currenciesAvailable() -> [String]
}

final class CurrencySDK: CurrencyService {
    var delegate: (any CurrencySDKDelegate)?
    
    private var service: NetworkService<OERResponse>?
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
        
    init(vendor: CurrencySDKVendors) {
        self.vendor = vendor
        setupService()
    }
    
    private func setupService() {
        switch self.vendor {
        case .openExchangeRates:
            self.service = OERService()
        }
        
        loadDataLocally()
    }
    
    func loadDataLocally() {
        // Load data from local cache
        
        
        let dataOutdated = true // When current data is older than 30 minutes
        if dataOutdated {
            Task {
                await loadDataFromRemote()
            }
        }
    }
    
    func loadDataFromRemote() async {
        // Load data from service, meant to be called once every 30 minutes
        do {
            let output = try await service?.fetch(request: OpenExchangeRateAPI.latest.request!)
            if let (response, urlResponse) = output {
                self.lastUpdatedEpoch = response.timestamp
                self.rates = response.rates
            }
        } catch {
            debugPrint(error)
        }
    }
    
    func saveDataLocally() {
        // Save data to local store so that cache can be used on next open
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
    
    
}

private extension CurrencySDK {
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

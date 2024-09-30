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

protocol CurrencySDKDelegate {
    /// Get notified whenever new rates are available
    func updatedRatesAvailable()
}

final class CurrencySDK {
    
    private var service: NetworkService<OERResponse>?
    private var vendor: CurrencySDKVendors
    private var delegate: CurrencySDKDelegate
    
    
    private var rates: [String: Double] = [:] {
        didSet {
            if rates != oldValue {
                updateCurrenciesAvailable()
            }
        }
    }
    
    private var currencies: [String] = []
        
    init(vendor: CurrencySDKVendors, delegate: CurrencySDKDelegate) {
        self.vendor = vendor
        self.delegate = delegate
        setupService()
    }
    
    private func setupService() {
        switch self.vendor {
        case .openExchangeRates:
            self.service = OERService()
        }
    }
    
    func updateCurrenciesAvailable() {
        defer {
            self.delegate.updatedRatesAvailable()
        }
        var newCurrencies = [String]()
        self.rates.forEach { currency, _ in
            newCurrencies.append(currency)
        }
        if self.currencies != newCurrencies {
            self.currencies = newCurrencies

        }
    }
    
    func loadDataLocally() {
        // Load data from local cache
    }
    
    func loadDataFromRemote() {
        // Load data from service, called once every 30 minutes
    }
    
    func saveDataLocally() {
        // Save data to local store so that cache can be used on next open
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

//
//  CurrencyConvertVM.swift
//  Swap Money
//
//  Created by Akashlal Bathe on 29/09/24.
//

import Foundation

@MainActor
final class CurrencyConvertVM: ObservableObject {
    var coordinator: Coordinator?
    var currencyService: CurrencyService?
    
    @Published var baseCurrency: String = "USD"
    @Published var currencies: [String] = []
    
    @Published var inputValue: Double = 1.0
    
    private var favourites: [String] = []
    
    init(coordinator: Coordinator?, currencyService: CurrencyService?) {
        self.coordinator = coordinator
        self.currencyService = currencyService ?? CurrencySDK(vendor: .openExchangeRates)
        
        self.currencyService?.delegate = self
    }
    
    func updateBaseCurrency(with currency: String) {
        self.baseCurrency = currency
    }
    
    func isFavourite(currency: String) -> Bool {
        return favourites.contains(currency)
    }
    
    func toggleFavourite(for currency: String) {
        if favourites.contains(currency) {
            favourites.removeAll { $0 == currency }
        } else {
            favourites.insert(currency, at: 0)
        }
        updateCurrencies()
    }
    
    func updateCurrencies() {
        var currencies = currencyService!.currenciesAvailable().filter{ !self.favourites.contains($0)
        }
        self.favourites.reversed().forEach {
            currencies.insert($0, at: 0)
        }
        self.currencies = currencies
    }
    
    func getValue(for currency: String, value: String) -> Double {
        let value = Double(value) ?? 1.0
        return currencyService?.convert(from: baseCurrency, to: currency, value: value) ?? 0
    }
    
}

extension CurrencyConvertVM: CurrencySDKDelegate {
    func updatedRatesAvailable() {
        self.updateCurrencies()
    }
    
}

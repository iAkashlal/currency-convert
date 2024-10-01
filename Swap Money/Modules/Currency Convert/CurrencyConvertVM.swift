//
//  CurrencyConvertVM.swift
//  Swap Money
//
//  Created by Akashlal Bathe on 29/09/24.
//

import Foundation

final class CurrencyConvertVM: ObservableObject {
    var coordinator: Coordinator?
    var currencyService: ExchangeRateService?
    
    @Published var baseCurrency: String = "USD"
    @Published var inputValue: String = "1"
    @Published var showError: Bool = false // Track whether to show the error message
    @Published var errorMessage: String? = nil // Error message to display
    @Published var isLoading: Bool = true  // Track loading state
    
    @Published var currencies: [String] = [] {
        didSet {
            self.isLoading = currencies.isEmpty
        }
    }
    
    private var favourites: [String] = []
    
    init(coordinator: Coordinator?, currencyService: ExchangeRateService?) {
        self.coordinator = coordinator
        self.currencyService = currencyService ?? ExchangeRateSDK(vendor: .openExchangeRates)
        
        self.setup()
    }
    
    func setCurrencyServiceDelegate() {
        self.currencyService?.delegate = self
    }
    
    private func setup() {
        Task {
            await MainActor.run {
                self.baseCurrency = UserSettings.preferredCurrency
            }
        }
        self.favourites = UserSettings.favouriteCurrencies
    }
    
    // Check if input is a valid number
    func validateInput() {
        if Double(inputValue) == nil {
            self.showError = true
            self.errorMessage = "Please enter a valid number"
        } else {
            self.showError = false
            self.errorMessage = nil
        }
    }
    
    func updateBaseCurrency(to currency: String) {
        let newCurrency = currency
        let newValue = getValue(for: newCurrency)
        self.baseCurrency = newCurrency
        UserSettings.preferredCurrency = newCurrency
        self.inputValue = "\(newValue)"
    }
    
    func isFavourite(currency: String) -> Bool {
        return favourites.contains(currency)
    }
    
    @MainActor
    func toggleFavourite(for currency: String) {
        if favourites.contains(currency) {
            favourites.removeAll { $0 == currency }
        } else {
            favourites.insert(currency, at: 0)
        }
        UserSettings.favouriteCurrencies = favourites
        updateCurrencies()
    }
    
    @MainActor
    func updateCurrencies() {
        guard let service = currencyService else { return }
        var currencies = service.currenciesAvailable().filter{ !self.favourites.contains($0) }
        self.favourites.reversed().forEach {
            currencies.insert($0, at: 0)
        }
        self.currencies = currencies
    }
    
    func getValue(for currency: String) -> Double {
        let value = Double(inputValue) ?? 1.0
        return currencyService?.convert(from: baseCurrency, to: currency, value: value) ?? 0
    }
    
}

extension CurrencyConvertVM: ExchangeRateSDKDelegate {
    @MainActor
    func updatedRatesAvailable() {
        self.updateCurrencies()
    }
    
}

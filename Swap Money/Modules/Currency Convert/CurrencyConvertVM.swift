import Foundation
import SwiftUI

@MainActor
final class CurrencyConvertVM: ObservableObject {
    var coordinator: Coordinator?
    var currencyService: ExchangeRateService?
    
    @Published var baseCurrency: String = "USD"
    @Published var inputValue: String = "1"
    @Published var showError: Bool = false // Track whether to show the error message
    @Published var errorMessage: String? = nil // Error message to display
    @Published var isLoading: Bool = true  // Track loading state
    @Published var animatedCurrency: String?
    @Published var animationStartRect: CGRect = .zero
    @Published var animationInProgress: Bool = false

    @Published var currencies: [String] = [] {
        didSet {
            self.isLoading = currencies.isEmpty
        }
    }
    
    private var favourites: [String] = []
    
    init(coordinator: Coordinator? = nil, currencyService: ExchangeRateService? = nil) {
        self.coordinator = coordinator
        self.currencyService = currencyService ?? ExchangeRateSDK(vendor: .openExchangeRates)
        
        self.setup()
    }
    
    func setCurrencyServiceDelegate() {
        self.currencyService?.delegate = self
    }
    
    private func setup() {
        self.baseCurrency = UserSettings.preferredCurrency
        self.favourites = UserSettings.favouriteCurrencies
        self.updateCurrencies()
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
    
    func swapButtonTapped(for currency: String, startRect: CGRect) {
        self.updateBaseCurrency(to: currency, startRect: startRect)
    }
    
    private func updateBaseCurrency(to currency: String, startRect: CGRect) {
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.5)) {
                self.animatedCurrency = currency
                self.animationStartRect = startRect
                self.animationInProgress = true
            }
        }
        
        UserSettings.preferredCurrency = currency
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.animationDidEnd()
        }
    }
    
    func animationDidEnd() {
        guard let animatedCurrency = self.animatedCurrency else { return }
        self.inputValue = "\(getValue(for: animatedCurrency))"
        self.baseCurrency = animatedCurrency
        self.animatedCurrency = nil
        self.animationInProgress = false
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
        var currencies = service.currenciesAvailable().filter { !self.favourites.contains($0) }
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
        DispatchQueue.main.async {
            self.updateCurrencies()
        }
    }
}

//
//  CurrencyConvertVM.swift
//  Swap Money
//
//  Created by Akashlal Bathe on 29/09/24.
//

import Foundation

final class CurrencyConvertVM: ObservableObject {
    var coordinator: Coordinator?
    var currencyService: CurrencyService?
    
    @Published var baseCurrency: String = "USD"
    
    init(coordinator: Coordinator?, currencyService: CurrencyService?) {
        self.coordinator = coordinator
        self.currencyService = currencyService ?? CurrencySDK(vendor: .openExchangeRates)
        
        self.currencyService?.delegate = self
    }
    
    func updateBaseCurrency(with currency: String) {
        self.baseCurrency = currency
    }
    
}

extension CurrencyConvertVM: CurrencySDKDelegate {
    func updatedRatesAvailable() {
        print(currencyService?.currenciesAvailableCount())
    }
    
}

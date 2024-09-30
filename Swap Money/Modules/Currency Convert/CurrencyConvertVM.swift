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
    
    init(coordinator: Coordinator?, currencyService: CurrencyService?) {
        self.coordinator = coordinator
        self.currencyService = currencyService ?? CurrencySDK(vendor: .openExchangeRates)
        
        self.currencyService?.delegate = self
    }
    
    func showConverter() {
        
    }
}

extension CurrencyConvertVM: CurrencySDKDelegate {
    func updatedRatesAvailable() {
        print(currencyService?.currenciesAvailableCount())
    }
    
}

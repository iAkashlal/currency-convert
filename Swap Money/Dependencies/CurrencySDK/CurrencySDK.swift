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

final class CurrencySDK {
    
    private var service: NetworkService<OERResponse>?
    private var vendor: CurrencySDKVendors
        
    init(vendor: CurrencySDKVendors) {
        self.vendor = vendor
        
        setupService()
    }
    
    private func setupService() {
        switch self.vendor {
        case .openExchangeRates:
            self.service = OERService()
        }
    }
    
    
}

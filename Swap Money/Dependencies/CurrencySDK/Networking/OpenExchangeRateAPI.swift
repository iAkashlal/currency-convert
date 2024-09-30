//
//  OpenExchangeRateAPI.swift
//  Swap Money
//
//  Created by Akashlal Bathe on 29/09/24.
//

import Foundation

enum OpenExchangeRateAPI {
    case latest
}

extension OpenExchangeRateAPI: NetworkRequest {
    var scheme: String {
        "https"
    }
    
    var host: String {
        "openexchangerates.org"
    }
    
    var version: String {
        "/api"
    }
    
    var path: String {
        switch self {
        case .latest:
            "/latest.json"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .latest:
                .get
        }
    }
    
    var headers: [String : String]? {
        ["content-type":"application/json"]
    }
    
    var body: Data? {
        nil
    }
    
    var queryParameters: [String : String] {
        switch self {
        case .latest:
            ["app_id": OpenExchangeRateAPIConstants.apiKey.rawValue]
        }
    }
    
    
}

enum OpenExchangeRateAPIConstants: String {
    case apiKey = "dc3bf65449f041ee9cd4e7c56a3ba69a"
}

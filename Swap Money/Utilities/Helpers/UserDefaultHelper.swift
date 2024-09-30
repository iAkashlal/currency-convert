//
//  UserDefault.swift
//  Swap Money
//
//  Created by Akashlal Bathe on 30/09/24.
//

import Foundation

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T

    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

struct UserSettings {
    @UserDefault(key: "hasSeenOnboarding", defaultValue: false)
    static var hasSeenOnboarding: Bool
    
    @UserDefault(key: "preferredCurrency", defaultValue: "USD")
    static var preferredCurrency: String
    
    @UserDefault(key: "favourites", defaultValue: ["JPY", "INR", "USD"])
    static var favouriteCurrencies: [String]
    
    
}

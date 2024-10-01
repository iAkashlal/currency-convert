//
//  UserDefaultPersistence.swift
//  Swap Money
//
//  Created by Akashlal Bathe on 30/09/24.
//

import Foundation

// Memento class responsible for saving and restoring OERResponse state
class UserDefaultPersistence<T: Codable>: LocalPersistence {
    
    private let userDefaultsKey = "com.akashlal.\(String(describing: T.self))Key"
    
    // Save the current state of the OERResponse to UserDefaults
    func saveState(_ response: T){
        // Encode OERResponse as Data
        if let encodedResponse = try? JSONEncoder().encode(response) {
            // Save the encoded response in UserDefaults
            UserDefaults.standard.set(encodedResponse, forKey: userDefaultsKey)
        }
    }
    
    // Restore the saved state of OERResponse from UserDefaults
    func restoreState() -> T? {
        // Retrieve the Data from UserDefaults
        if let savedResponseData = UserDefaults.standard.data(forKey: userDefaultsKey) {
            // Decode the Data back to OERResponse
            if let decodedResponse = try? JSONDecoder().decode(T.self, from: savedResponseData) {
                return decodedResponse
            }
        }
        return nil
    }
    
    // Clear the saved state from UserDefaults
    func clearState() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}

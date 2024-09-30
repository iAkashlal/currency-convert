//
//  LocalPersistence.swift
//  Swap Money
//
//  Created by Akashlal Bathe on 30/09/24.
//

import Foundation

protocol LocalPersistence {
    func saveState(_ response: OERResponse)
    func restoreState() -> OERResponse?
    func clearState()
    
}

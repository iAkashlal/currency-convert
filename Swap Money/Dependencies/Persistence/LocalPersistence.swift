//
//  LocalPersistence.swift
//  Swap Money
//
//  Created by Akashlal Bathe on 30/09/24.
//

import Foundation

protocol LocalPersistence {
    associatedtype T: Codable
    func saveState(_ response: T)
    func restoreState() -> T?
    func clearState()
}

class AnyLocalPersistence<T: Codable>: LocalPersistence {
    private let _saveState: (T) -> Void
    private let _restoreState: () -> T?
    private let _clearState: () -> Void
    
    init<P: LocalPersistence>(_ persistence: P) where P.T == T {
        self._saveState = persistence.saveState
        self._restoreState = persistence.restoreState
        self._clearState = persistence.clearState
    }
    
    func saveState(_ response: T) {
        _saveState(response)
    }
    
    func restoreState() -> T? {
        return _restoreState()
    }
    
    func clearState() {
        _clearState()
    }
}

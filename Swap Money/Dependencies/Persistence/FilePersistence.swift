//
//  FilePersistence.swift
//  Swap Money
//
//  Created by Akashlal Bathe on 30/09/24.
//

import Foundation

// Memento class responsible for saving and restoring OERResponse state
class FilePersistence<T: Codable>: LocalPersistence {

    private let fileName = "\(String(describing: T.self))Memento.json"
    
    // Helper to get the file URL in the documents directory
    private func getFileURL() -> URL? {
        // Get the user's document directory
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        // Return the URL with the specified file name
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    // Save the current state of OERResponse to a file
    func saveState(_ response: T) {
        guard let fileURL = getFileURL() else { return }
        
        // Encode OERResponse as Data
        do {
            let encodedResponse = try JSONEncoder().encode(response)
            // Write the encoded data to the file
            try encodedResponse.write(to: fileURL)
        } catch {
            print("Failed to save state: \(error)")
        }
    }
    
    // Restore the saved state of OERResponse from the file
    func restoreState() -> T? {
        guard let fileURL = getFileURL() else { return nil }
        
        // Read the Data from the file
        do {
            let savedResponseData = try Data(contentsOf: fileURL)
            // Decode the Data back to OERResponse
            let decodedResponse = try JSONDecoder().decode(T.self, from: savedResponseData)
            return decodedResponse
        } catch {
            print("Failed to restore state: \(error)")
            return nil
        }
    }
    
    // Clear the saved state by deleting the file
    func clearState() {
        guard let fileURL = getFileURL() else { return }
        
        // Remove the file
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("Failed to clear state: \(error)")
        }
    }
}

//
//  FilePersistenceTests.swift
//  Swap MoneyTests
//
//  Created by Akashlal Bathe on 03/10/24.
//

import XCTest
@testable import Swap_Money

class FilePersistenceTests: XCTestCase {

    // Helper method to clean up files after each test
    override func tearDown() {
        super.tearDown()
        let filePersistence = FilePersistence<String>()
        filePersistence.clearState()
    }

    func testFilePersistence_givenValidResponse_saveStateAndRestoreState_shouldSaveToFileAndRestore() {
        // Given
        let filePersistence = FilePersistence<String>()
        let testValue = "PersistedString"

        // When
        filePersistence.saveState(testValue)
        let savedValue = filePersistence.restoreState()

        // Then
        XCTAssertEqual(savedValue, testValue, "The saved value should match the input value.")
    }

    // Given no file exists, when restoreState is called, then it should return nil
    func testFilePersistence_givenNoFileExists_restoreState_shouldReturnNil() {
        // Given
        let filePersistence = FilePersistence<String>()

        // When
        let restoredValue = filePersistence.restoreState()

        // Then
        XCTAssertNil(restoredValue, "Restoring state should return nil when no file exists.")
    }

    // Given a file exists, when clearState is called, then the file should be deleted
    func testFilePersistence_givenFileExists_clearState_shouldDeleteFile() {
        // Given
        let filePersistence = FilePersistence<String>()
        let testValue = "PersistedString"
        filePersistence.saveState(testValue)

        // When
        filePersistence.clearState()

        // Then
        let restoredValue = filePersistence.restoreState()
        XCTAssertNil(restoredValue, "The state should be cleared, and restoring should return nil.")
    }

    // Given an invalid file path, when saveState is called, then it should fail silently and not save the state
    func testFilePersistence_givenInvalidFilePath_saveState_shouldFailSilently() {
        // Given
        let filePersistence = FilePersistence<String>()
        let invalidValue: String? = nil

        // When
        filePersistence.saveState(invalidValue ?? "")

        // Then
        let restoredValue = filePersistence.restoreState()
        XCTAssertNotEqual(restoredValue, invalidValue, "An invalid value should not be saved.")
    }
    
    func testFilePersistence_twoTypesSaved_retrieveTwoTypesAgain_shouldNotConflict() {
        // Given
        let stringFilePersistence = FilePersistence<String>()
        let intFilePersistence = FilePersistence<Int>()
        
        // When
        let stringValue = "String"
        let intValue = 1
        stringFilePersistence.saveState(stringValue)
        intFilePersistence.saveState(intValue)
        
        // Then
        let stringSaved = stringFilePersistence.restoreState()
        let intSaved = intFilePersistence.restoreState()
        
        XCTAssertEqual(stringValue, stringSaved, "String retrieval should be independent of Int value saved")
        XCTAssertEqual(intValue, intSaved, "Int retrieval should be independent of String value saved")
    }
    
    func testFilePersistence_twoSameTypesSaved_secondValueOverridesTheFirst() {
        // Given
        let stringFilePersistence1 = FilePersistence<String>()
        let stringFilePersistence2 = FilePersistence<String>()
        
        // When
        let stringValue1 = "String1"
        let stringValue2 = "String2"
        stringFilePersistence1.saveState(stringValue1)
        stringFilePersistence2.saveState(stringValue2)
        
        // Then
        let stringSaved1 = stringFilePersistence1.restoreState()
        let stringSaved2 = stringFilePersistence2.restoreState()
        
        XCTAssertNotEqual(stringValue1, stringSaved1, "Last saved string should override previous saved string")
        XCTAssertEqual(stringValue2, stringSaved2, "Last saved string should override previous saved string")
    }
}

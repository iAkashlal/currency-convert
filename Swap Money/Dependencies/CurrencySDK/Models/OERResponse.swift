//
//  OERResponse.swift
//  Swap Money
//
//  Created by Akashlal Bathe on 29/09/24.
//

import Foundation

struct OERResponse: Codable {
    let timestamp: Int
    let base: String
    let rates: [String: Double]
}

//
//  Trip.swift
//  Swap Money
//
//  Created by Akashlal Bathe on 12/10/24.
//

import Foundation

struct Trip: Identifiable {
    let id = UUID()
    let location: String
    let startDate: Date
    let endDate: Date
}

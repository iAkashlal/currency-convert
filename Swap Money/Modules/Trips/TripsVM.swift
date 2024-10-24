//
//  TripsVM.swift
//  Swap Money
//
//  Created by Akashlal Bathe on 12/10/24.
//

import Foundation
import SwiftUI

class TripsVM: ObservableObject  {
    @Published var trips: [Trip] = []
    
    func loadTrips() {
        let trips = [Trip]()
        
        for index in 0...3 {
            self.trips.append(Trip(location: "Location \(index)", startDate: Date(), endDate: Date()))
        }
    }
    
}

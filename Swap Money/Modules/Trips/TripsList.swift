//
//  TripsList.swift
//  Swap Money
//
//  Created by Akashlal Bathe on 12/10/24.
//

import SwiftUI

// List of trips
// Add a new trip
// If empty, add a new trip direclty
// Tab - upcoming trips, Past trips, current trips
//

struct TripsList: View {
    
    @StateObject private var viewModel = TripsVM()
    
    var body: some View {
        Text("Trips!")
        List {
            ForEach(viewModel.trips) { trip  in
                Text("Trip to" + trip.location)
            }
        }
        .background()
    }
}

#Preview {
    TripsList()
}

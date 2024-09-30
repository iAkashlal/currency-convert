//
//  OnboardingVM.swift
//  Swap Money
//
//  Created by Akashlal Bathe on 29/09/24.
//

import Foundation

final class OnboardingVM: ObservableObject {
    var coordinator: OnboardingCoordinator?
    
    let features = [
        ("Convert Currency Easily", "Choose your currency, Input any amount and get conversion rates for various other currencies."),
        ("View Multiple Currencies", "See the value of your currency across various currencies instantly in one glance."),
        ("Accurate & Up-to-date", "Rates are fetched from reliable sources to ensure you get the most accurate conversions."),
        ("Favorites & History", "*Upcoming* Save your frequent conversions and view past conversions for quick access."),
        ("Multi-Language Support", "*Upcoming* The app supports multiple languages for global accessibility.")
    ]
    
    init(coordinator: OnboardingCoordinator?) {
        self.coordinator = coordinator
    }
    
    @MainActor
    func completeOnboarding() {
        // Update some persisted variable
        
        // Use coordinator to shift flow
        self.coordinator?.onboardUser()
    }
}

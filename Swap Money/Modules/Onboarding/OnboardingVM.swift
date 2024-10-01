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
        ("eurozonesign.arrow.trianglehead.counterclockwise.rotate.90", "Convert Currencies Easily", "Choose your currency, Input any amount and get conversion rates for various other currencies."),
        ("list.bullet.indent", "View Multiple Currencies", "See the value of your currency across various currencies instantly in one glance."),
        ("square.stack.3d.up.badge.automatic", "Accurate & Up-to-date", "Rates are fetched from reliable sources to ensure you get the most accurate conversions."),
        ("star.square.on.square", "Favorites & History", "*Upcoming* Save your frequent conversions and view past conversions for quick access."),
        ("translate", "Multi-Language Support", "*Upcoming* The app supports multiple languages for global accessibility.")
    ]
    
    init(coordinator: OnboardingCoordinator?) {
        self.coordinator = coordinator
    }
    
    @MainActor
    func completeOnboarding() {
        // Update some persisted variable
        UserSettings.hasSeenOnboarding = true
        
        // Use coordinator to shift flow
        self.coordinator?.onboardUser()
    }
}

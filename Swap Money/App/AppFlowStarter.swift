//
//  AppFlowStarter.swift
//  Swap Money
//
//  Created by Akashlal Bathe on 29/09/24.
//

import UIKit

final class AppFlowStarter {
    
    // Different Flows for sequence of pages
    enum FlowPath {
        case onboarding
        case currencyConvert
    }
    
    private init() {}
    
    static let shared = AppFlowStarter()
    
    @MainActor
    func setup(
        path: FlowPath,
        with rootCoordinator: inout Coordinator?,
        in window: UIWindow?
    ) {
        let navigationController = UINavigationController()
        window?.rootViewController = navigationController
        
        let coordinator: Coordinator?
        
        switch path{
        case .currencyConvert:
            coordinator = CurrencyConvertCoordinator(
                childCoordinators: [],
                navigationController: navigationController
            )
        case .onboarding:
            coordinator = OnboardingCoordinator(
                childCoordinators: [],
                navigationController: navigationController
            )
        }
        
        coordinator?.start()
        
    }
}


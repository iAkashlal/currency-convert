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
    
    private let navigationController = UINavigationController()
    
    @MainActor
    func setup(
        path: FlowPath,
        in window: UIWindow?
    ) {
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
    
    @MainActor
    func replaceFlow(with flowPath: FlowPath) {
        navigationController.popViewController(animated: false)
        self.setup(path: flowPath, in: nil)
    }
}


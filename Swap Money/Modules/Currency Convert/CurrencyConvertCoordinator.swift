//
//  CurrencyConvertCoordinator.swift
//  Swap Money
//
//  Created by Akashlal Bathe on 29/09/24.
//

import SwiftUI
import UIKit

@MainActor
class CurrencyConvertCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    
    var navigationController: UINavigationController?
    
    init(childCoordinators: [any Coordinator], navigationController: UINavigationController? = nil) {
        self.childCoordinators = childCoordinators
        self.navigationController = navigationController
    }
    
    func start() {
        let currencyConvertVM = CurrencyConvertVM(coordinator: self)
        
        let currencyConvertView = OnboardingView()
        
        guard let navigationController else {
            Logger.sharedInstance.log(message: "Navigation Controller not setup properly \(#file)")
            return
        }
        
        navigationController.setViewControllers(
            [UIHostingController(rootView: currencyConvertView)],
            animated: true
        )
    }
    
    
}

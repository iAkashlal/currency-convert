//
//  OnboardingCoordinator.swift
//  Swap Money
//
//  Created by Akashlal Bathe on 29/09/24.
//

import SwiftUI
import UIKit

@MainActor
class OnboardingCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    
    var navigationController: UINavigationController?
    
    init(childCoordinators: [any Coordinator], navigationController: UINavigationController? = nil) {
        self.childCoordinators = childCoordinators
        self.navigationController = navigationController
    }
    
    func start() {
        let onboardingVM = OnboardingVM(coordinator: self)
        
        let onboardingView = OnboardingView(viewModel: onboardingVM)
        
        guard let navigationController else {
            Logger.sharedInstance.log(message: "Navigation Controller not setup properly \(#file)")
            return
        }
        
        navigationController.setViewControllers(
            [UIHostingController(rootView: onboardingView)],
            animated: true
        )
    }
    
    func onboardUser() {
        
    }
    
    
}

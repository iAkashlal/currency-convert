//
//  Coordinator.swift
//  Swap Money
//
//  Created by Akashlal Bathe on 29/09/24.
//

import UIKit

protocol Coordinator {
    var childCoordinators: [any Coordinator] {get set}
    var navigationController: UINavigationController? {get set}
    
    func start()    // Load up first ViewController that's needed to render the flow
    
    
}

//
//  Coordinator.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/07.
//

import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController {get set}
    var childCoordinators: [Coordinator] {get set}
    var delegate: CoordinatorDelegate? {get set}
    
    init(navigationController: UINavigationController)
    
    func start()
}

protocol CoordinatorDelegate: AnyObject {
    func didFinished(childCoordinator: Coordinator)
}

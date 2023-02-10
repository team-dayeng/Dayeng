//
//  AppCoordinator.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/09.
//

import UIKit
import RxSwift

protocol AppCoordinatorProtocol: Coordinator {
    func showSplashViewController()
    func showLoginViewController()
    func showMainViewController()
}

final class AppCoordinator: AppCoordinatorProtocol {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var delegate: CoordinatorDelegate?
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showSplashViewController()
    }
    
    func showSplashViewController() {
        let viewModel = SplashViewModel()
        let viewController = SplashViewController(viewModel: viewModel)
        navigationController.viewControllers = [viewController]
    }
    
    func showLoginViewController() {
        let viewModel = LoginViewModel()
        let viewController = LoginViewController()
        navigationController.pushViewController(viewController, animated: false)
    }
    
    func showMainViewController() {
        let coordinator = MainCoordinator(navigationController: navigationController)
        childCoordinators.append(coordinator)
        coordinator.start()
    }
}

extension AppCoordinator: CoordinatorDelegate {
    func didFinished(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter({ $0 !== childCoordinator })
    }
}

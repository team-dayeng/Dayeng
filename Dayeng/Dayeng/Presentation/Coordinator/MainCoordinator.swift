//
//  MainCoordinator.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/10.
//

import UIKit

protocol MainCoordinatorProtocol: Coordinator {
    func showMainViewController()
}

final class MainCoordinator: MainCoordinatorProtocol {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var delegate: CoordinatorDelegate?
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showMainViewController()
    }
    
    func showMainViewController() {
        let viewController = MainViewController(viewModel: MainViewModel())
        navigationController.viewControllers = [viewController]
    }
    
    func showCalendarViewController(ownerType: OwnerType) {
        let viewModel = CalendarViewModel(ownerType: ownerType)
        let viewController = CommonCalendarViewController(ownerType: ownerType)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showFriendViewController() {
        let coordinator = FriendCoordinator(navigationController: navigationController)
        childCoordinators.append(coordinator)
        coordinator.start()
    }
    
    func showSettingViewController() {
        let coordinator = SettingCoordinator(navigationController: navigationController)
        childCoordinators.append(coordinator)
        coordinator.start()
    }
}

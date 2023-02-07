//
//  FriendCoordiantor.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/07.
//

import UIKit

protocol FriendCoordinatorProtocol: Coordinator {
    func showFriendViewController()
}

final class FriendCoordinator: FriendCoordinatorProtocol {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var delegate: CoordinatorDelegate?
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showFriendViewController()
    }
    
    
    func showFriendViewController() {
        let viewModel = FriendListViewModel()
        let viewController = FriendListViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}

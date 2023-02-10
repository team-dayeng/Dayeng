//
//  FriendCoordinator.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/10.
//

import UIKit
import RxSwift
import RxRelay

protocol FriendCoordinatorProtocol: Coordinator {
    func showFriendViewController()
}

final class FriendCoordinator: FriendCoordinatorProtocol {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var delegate: CoordinatorDelegate?
    var disposeBag = DisposeBag()
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showFriendViewController()
    }
    
    func showFriendViewController() {
        let viewModel = FriendListViewModel()
        let viewController = FriendListViewController(viewModel: viewModel)
        viewModel.plusButtonDidTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.showAddFriendViewController()
            })
            .disposed(by: disposeBag)
        viewModel.friendIndexDidTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.showFriendCalendarViewController()
            })
            .disposed(by: disposeBag)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showAddFriendViewController() {
        let viewController = AddFriendViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showFriendCalendarViewController() {
        let viewModel = CalendarViewModel()
        let viewController = CalendarViewController(ownerType: .friend,
                                                    viewModel: viewModel)
        viewModel.homeButtonDidTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.returnMainViewController()
            })
            .disposed(by: disposeBag)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func returnMainViewController() {
        navigationController.popToRootViewController(animated: true)
    }
}

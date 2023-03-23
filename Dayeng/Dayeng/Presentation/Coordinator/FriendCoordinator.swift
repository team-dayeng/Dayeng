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
    func showAddFriendViewController()
    func showFriendCalendarViewController(user: User)
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
        let firestoreService = DefaultFirestoreDatabaseService()
        let useCase = DefaultFriendListUseCase(
            userRepository: DefaultUserRepository(firestoreService: firestoreService)
        )
        let viewModel = FriendListViewModel(useCase: useCase)
        let viewController = FriendListViewController(viewModel: viewModel)
        
        viewModel.plusButtonDidTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.showAddFriendViewController()
            })
            .disposed(by: disposeBag)
        
        viewModel.friendIndexDidTapped
            .subscribe(onNext: { [weak self] user in
                guard let self else { return }
                self.showFriendCalendarViewController(user: user)
            })
            .disposed(by: disposeBag)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showAddFriendViewController() {
        let firestoreService = DefaultFirestoreDatabaseService()
        let useCase = DefaultAddFriendUseCase(
            userRepository: DefaultUserRepository(firestoreService: firestoreService),
            linkBuilderService: DefaultLinkBuildService()
        )
        let viewModel = AddFriendViewModel(useCase: useCase)
        let viewController = AddFriendViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showFriendCalendarViewController(user: User) {
        let firestoreService = DefaultFirestoreDatabaseService()
        let useCase = DefaultCalendarUseCase(
            userRepository: DefaultUserRepository(firestoreService: firestoreService)
        )
        let viewModel = CalendarViewModel(useCase: useCase, ownerType: .friend(user: user))
        let viewController = CalendarViewController(viewModel: viewModel)
        viewModel.homeButtonDidTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.returnMainViewController()
            })
            .disposed(by: disposeBag)
        
        viewModel.cannotFindUserError
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.navigationController.showAlert(
                    title: AlertMessageType.cannotFindUser.title,
                    message: AlertMessageType.cannotFindUser.message,
                    type: .oneButton,
                    rightActionHandler: { [weak self] in
                        guard let self else { return }
                        self.navigationController.viewControllers.last?.hideIndicator()
                        self.delegate?.didFinished(childCoordinator: self)
                })
            })
            .disposed(by: disposeBag)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func returnMainViewController() {
        navigationController.popToRootViewController(animated: true)
    }
}

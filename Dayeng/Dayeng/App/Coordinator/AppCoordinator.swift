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
    var disposeBag = DisposeBag()
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showSplashViewController()
    }
    
    func showSplashViewController() {
        let firestoreService = DefaultFirestoreDatabaseService()
        let useCase = DefaultSplashUseCase(
            userRepository: DefaultUserRepository(firestoreService: firestoreService),
            questionRepository: DefaultQuestionRepository(firestoreService: firestoreService)
        )
        let viewModel = SplashViewModel(useCase: useCase)
        let viewController = SplashViewController(viewModel: viewModel)
        
        viewModel.loginStatus
            .subscribe(onNext: { [weak self] result in
                guard let self else { return }
                if result {
                    DispatchQueue.main.async {
                        self.showMainViewController()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showLoginViewController()
                    }
                }
            })
            .disposed(by: disposeBag)

        navigationController.viewControllers = [viewController]
    }
    
    func showLoginViewController() {
        let firestoreService = DefaultFirestoreDatabaseService()
        let userRepository = DefaultUserRepository(firestoreService: firestoreService)
        let useCase = DefaultLoginUseCase(userRepository: userRepository)
        let viewModel = LoginViewModel(useCase: useCase)
        let viewController = LoginViewController(viewModel: viewModel)
        
        viewModel.loginSuccess
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.showMainViewController()
            })
            .disposed(by: disposeBag)
        
        navigationController.viewControllers = [viewController]
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

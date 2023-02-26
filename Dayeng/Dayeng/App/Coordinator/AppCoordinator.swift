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
        
        Observable.zip(viewModel.loginStatus, viewModel.dataDidLoad)
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (loginResult, _) in
                guard let self else { return }
                    if loginResult {
                        self.showMainViewController()
                    } else {
                        self.showLoginViewController()
                    }
            }, onError: { [weak self] error in
                guard let self else { return }
                print(error.localizedDescription)
                self.navigationController.showAlert(
                    title: "네트워크에 연결되지 않았습니다.",
                    message: "다시 시도해주세요.",
                    type: .oneButton,
                    rightActionHandler: { [weak self] in
                        guard let self else { return }
                        self.showSplashViewController()
                })
            })
            .disposed(by: disposeBag)

        navigationController.viewControllers = [viewController]
    }
    
    func showLoginViewController() {
        
        if !childCoordinators.isEmpty {
            childCoordinators.removeAll()
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = navigationController
            }
        }
        
        let firestoreService = DefaultFirestoreDatabaseService()
        let userRepository = DefaultUserRepository(firestoreService: firestoreService)
        let appleLoginService = DefaultAppleLoginService()
        let kakaoLoginService = DefaultKakaoLoginService()
        let useCase = DefaultLoginUseCase(
            userRepository: userRepository,
            appleLoginService: appleLoginService,
            kakaoLoginService: kakaoLoginService
        )
        let viewModel = LoginViewModel(useCase: useCase)
        let viewController = LoginViewController(viewModel: viewModel)
        
        viewModel.loginResult
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

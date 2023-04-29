//
//  MainCoordinator.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/10.
//

import UIKit
import RxSwift
import RxRelay

protocol MainCoordinatorProtocol: Coordinator {
    func showMainViewController()
    func showCalendarViewController(ownerType: OwnerType) -> Observable<Int>
    func showFriendViewController()
    func showSettingViewController()
}

final class MainCoordinator: MainCoordinatorProtocol {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var delegate: CoordinatorDelegate?
    var disposeBag = DisposeBag()
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showMainViewController()
    }
    
    func showMainViewController() {
        let firestoreService = DefaultFirestoreDatabaseService()
        let userRepository = DefaultUserRepository(firestoreService: firestoreService)
        let questionRepository = DefaultQuestionRepository(firestoreService: firestoreService)
        let useCase = DefaultMainUseCase(userRepository: userRepository,
                                         questionRepository: questionRepository,
                                         ownerType: .mine)
        let viewModel = MainViewModel(useCase: useCase)
        let viewController = MainViewController(viewModel: viewModel)
        
        viewModel.friendButtonDidTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.showFriendViewController()
            })
            .disposed(by: disposeBag)
        viewModel.settingButtonDidTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.showSettingViewController()
            })
            .disposed(by: disposeBag)
        viewModel.calendarButtonDidTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.showCalendarViewController(ownerType: .mine)
                    .bind(to: useCase.firstShowingIndex)
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        viewModel.editButtonDidTapped
            .subscribe(onNext: { [weak self] (index: Int) in
                guard let self else { return }
                self.showEditViewController(index: index)
            })
            .disposed(by: disposeBag)
        
        viewModel.cannotFindUserError
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.showCannotFindUserAlert()
            })
            .disposed(by: disposeBag)
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?
            .changeRootViewController(navigationController, viewController)
    }
    
    func showCalendarViewController(ownerType: OwnerType) -> Observable<Int> {
        let firestoreService = DefaultFirestoreDatabaseService()
        let useCase = DefaultCalendarUseCase(
            userRepository: DefaultUserRepository(firestoreService: firestoreService),
            ownerType: ownerType
        )
        let viewModel = CalendarViewModel(useCase: useCase)
        let viewController = CalendarViewController(viewModel: viewModel)
        
        viewModel.cannotFindUserError
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.showCannotFindUserAlert()
            })
            .disposed(by: disposeBag)
        
        navigationController.pushViewController(viewController, animated: true)
        
        return viewModel.dayDidTapped
            .do(onNext: { [weak self] _ in
                guard let self else { return }
                self.navigationController.popViewController(animated: true)
            })
    }
    
    func showFriendViewController() {
        let coordinator = FriendCoordinator(navigationController: navigationController)
        childCoordinators.append(coordinator)
        coordinator.start()
    }
    
    func showSettingViewController() {
        let coordinator = SettingCoordinator(navigationController: navigationController)
        coordinator.delegate = self
        childCoordinators.append(coordinator)
        coordinator.start()
    }
    
    func showEditViewController(index: Int) {
        let firestoreService = DefaultFirestoreDatabaseService()
        let userRepository = DefaultUserRepository(firestoreService: firestoreService)
        let useCase = DefaultMainEditUseCase(userRepository: userRepository, index: index)
        let viewModel = MainEditViewModel(useCase: useCase)
        let viewController = MainEditViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showCannotFindUserAlert() {
        navigationController.showAlert(
            title: AlertMessageType.cannotFindUser.title,
            message: AlertMessageType.cannotFindUser.message,
            type: .oneButton,
            rightActionHandler: { [weak self] in
                guard let self else { return }
                self.navigationController.viewControllers.last?.hideIndicator()
                self.delegate?.didFinished(childCoordinator: self)
        })
    }
}

extension MainCoordinator: CoordinatorDelegate {
    func didFinished(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter({ $0 !== childCoordinator })
        delegate?.didFinished(childCoordinator: self)
    }
}

//
//  SettingCoordinator.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/10.
//

import UIKit
import RxSwift
import RxRelay

protocol SettingCoordinatorProtocol: Coordinator {
    func showSettingViewController()
    func showAlarmSettingViewController()
}

final class SettingCoordinator: NSObject, SettingCoordinatorProtocol {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var delegate: CoordinatorDelegate?
    var disposeBag = DisposeBag()
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showSettingViewController()
    }
    
    func showSettingViewController() {
        let useCase = DefaultSettingUseCase(
            appleLoginService: DefaultAppleLoginService(),
            kakaoLoginService: DefaultKakaoLoginService()
        )
        let viewModel = SettingViewModel(useCase: useCase)
        let viewController = SettingViewController(viewModel: viewModel)
        viewModel.alarmCellDidTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.showAlarmSettingViewController()
            })
            .disposed(by: disposeBag)
        viewModel.openSourceCellDidTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.showWebViewController(url: PageType.openSource.url)
            })
            .disposed(by: disposeBag)
        viewModel.aboutCellDidTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.showWebViewController(url: PageType.about.url)
            })
            .disposed(by: disposeBag)
        viewModel.logoutSuccess
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.navigationController.viewControllers.last?.hideIndicator()
                self.delegate?.didFinished(childCoordinator: self)
            })
            .disposed(by: disposeBag)
        viewModel.withdrawalSuccess
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.navigationController.viewControllers.last?.hideIndicator()
                self.delegate?.didFinished(childCoordinator: self)
            })
            .disposed(by: disposeBag)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showWebViewController(url: String) {
        let viewController = WebViewController(url: url)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showAlarmSettingViewController() {
        let useCase = DefaultAlarmSettingUseCase(userNotificationService: DefaultUserNotificationService())
        let viewModel = AlarmSettingViewModel(useCase: useCase)
        viewModel.daysOfWeekDidTapped
            .subscribe(onNext: { [weak self] selectedDays in
                guard let self else { return }
                self.showAlarmDaySettingViewController(selectedDays: selectedDays)
            }).disposed(by: disposeBag)
        let viewController = AlarmSettingViewController(alarmSettingViewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showAlarmDaySettingViewController(selectedDays: BehaviorRelay<[Bool]>) {
        let viewController = AlarmDaySettingViewController(isSelectedCells: selectedDays)
        navigationController.pushViewController(viewController, animated: true)
    }
}

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

final class SettingCoordinator: SettingCoordinatorProtocol {
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
        let viewModel = SettingViewModel()
        viewModel.alarmCellDidTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.showAlarmSettingViewController()
            }).disposed(by: disposeBag)
        
        let viewController = SettingViewController(viewModel: viewModel)
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

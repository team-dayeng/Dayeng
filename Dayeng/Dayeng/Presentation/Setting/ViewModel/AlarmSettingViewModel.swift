//
//  AlarmSettingViewModel.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/10.
//

import Foundation
import RxSwift
import RxRelay

final class AlarmSettingViewModel {
    // MARK: - Input
    struct Input {
        var registButtonDidTapped: Observable<Date>
        var daysOfWeekDidTapped: Observable<Void>
    }
    // MARK: - Output
    struct Output {
        var dayList = PublishRelay<String>()
        var date = PublishRelay<Date>()
    }
    // MARK: - Dependency
    var disposeBag = DisposeBag()
    let useCase: AlrarmSettingUseCase
    let daysOfWeekDidTapped = PublishSubject<BehaviorRelay<[Bool]>>()
    
    // MARK: - LifeCycle
    init(useCase: AlrarmSettingUseCase) {
        self.useCase = useCase
    }
    
    // MARK: - Helper
    func transform(input: Input) -> Output {
        let output = Output()
        input.daysOfWeekDidTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.daysOfWeekDidTapped.onNext(self.useCase.selectedDays)
            }).disposed(by: disposeBag)
        
        input.registButtonDidTapped
            .subscribe(onNext: { date in
                
        input.isAlarmSwitchOn
            .subscribe(onNext: { isOn in
                if isOn {
                    self.useCase.onAlarm()
                        .subscribe(onError: { _ in
                            output.isSuccessRegistResult.accept(false)
                        }).disposed(by: self.disposeBag)
                } else {
                    self.useCase.offAlarm()
                }
            }).disposed(by: disposeBag)
        return output
    }
}

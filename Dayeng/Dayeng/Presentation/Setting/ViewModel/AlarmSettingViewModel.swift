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
        var viewWillAppear: Observable<Void>
        var viewDidLoad: Observable<Void>
        var registButtonDidTapped: Observable<Date>
        var daysOfWeekDidTapped: Observable<Void>
        var isAlarmSwitchOn: Observable<Bool>
    }
    // MARK: - Output
    struct Output {
        var initialyIsAlarmOn = ReplayRelay<Bool>.create(bufferSize: 1)
        var dayList = PublishRelay<String>()
        var setDate = ReplayRelay<Date>.create(bufferSize: 1)
        var isSuccessRegistResult = PublishRelay<Bool>()
    }
    // MARK: - Dependency
    var disposeBag = DisposeBag()
    let useCase: AlarmSettingUseCase
    let daysOfWeekDidTapped = PublishSubject<BehaviorRelay<[Bool]>>()
    
    // MARK: - LifeCycle
    init(useCase: AlarmSettingUseCase) {
        self.useCase = useCase
    }
    
    // MARK: - Helper
    func transform(input: Input) -> Output {
        let output = Output()
        
        self.useCase.initialyIsAlarmOn
            .bind(to: output.initialyIsAlarmOn)
           .disposed(by: self.disposeBag)
        
        self.useCase.alarmDate
            .bind(to: output.setDate)
            .disposed(by: self.disposeBag)
        
        input.viewWillAppear
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                output.dayList.accept(self.useCase.selectedDaysDescription)
            }).disposed(by: disposeBag)
        
        input.daysOfWeekDidTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.daysOfWeekDidTapped.onNext(self.useCase.selectedDays)
            }).disposed(by: disposeBag)
        
        input.registButtonDidTapped
            .subscribe(onNext: { [weak self] date in
                guard let self else { return }
                self.useCase.registAlarm(date)
                    .subscribe(onNext: {
                        output.isSuccessRegistResult.accept(true)
                    }, onError: { _ in
                        output.isSuccessRegistResult.accept(false)
                    }).disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
        
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

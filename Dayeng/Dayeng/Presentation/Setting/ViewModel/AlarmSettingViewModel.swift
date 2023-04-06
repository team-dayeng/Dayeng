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
    enum RegistResult {
        case notAuthorized
        case notInputDays
        case success(String, Date)
        case change(Bool)
    }
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
        var initialyIsAlarmOn = PublishSubject<Bool>()
        var dayList = PublishRelay<String>()
        var setDate = ReplayRelay<Date>.create(bufferSize: 1)
        var registResult = PublishRelay<RegistResult>()
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
        
        useCase.checkInitialyIsAlarmOn()
            .bind(to: output.initialyIsAlarmOn)
            .disposed(by: disposeBag)
        
        useCase.alarmDate
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
                guard self.useCase.selectedDays.value != Array(repeating: false, count: 7) else {
                    output.registResult.accept(.notInputDays)
                    return
                }
                self.useCase.registAlarm(date)
                    .subscribe(onNext: { allow in
                        if allow {
                            output.registResult.accept(.success(self.useCase.selectedDaysDescription,
                                                                date))
                        } else {
                            output.registResult.accept(.notAuthorized)
                        }
                    }).disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
        
        input.isAlarmSwitchOn
            .subscribe(onNext: { isOn in
                if isOn {
                    self.useCase.onAlarm()
                        .subscribe(onNext: { allow in
                            if allow {
                                output.registResult.accept(.change(allow))
                            } else {
                                output.registResult.accept(.notAuthorized)
                            }
                        }).disposed(by: self.disposeBag)
                } else {
                    self.useCase.offAlarm()
                    output.registResult.accept(.change(false))
                }
            }).disposed(by: disposeBag)
        return output
    }
}

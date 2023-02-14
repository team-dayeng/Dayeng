//
//  DefaultAlrarmSettingUseCase.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/10.
//

import Foundation
import UserNotifications
import RxRelay
import RxSwift

final class DefaultAlrarmSettingUseCase: AlrarmSettingUseCase {
    private let userNotificationService: UserNotificationService
    
    private var disposeBag = DisposeBag()
    var selectedDays: BehaviorRelay<[Bool]>
    var alarmDate: BehaviorRelay<Date>
    var isAlarmOn: BehaviorRelay<Bool>
    var isAuthorized = PublishRelay<Bool>()
    
    var selectedDaysDescription: String {
        let koreanDays = ["월", "화", "수", "목", "금", "토", "일"]
        let days = selectedDays.value
            .enumerated()
            .map { $0.element ? koreanDays[$0.offset] : "" }
            .joined()
        
        if days == "" { return "안 함" }
        if days == "월화수목금토일" { return "매일" }
        if days == "토일" { return "주말" }
        if days == "월화수목금" { return "주중" }
        
        return Array(days).map {String($0)}.joined(separator: " ")
    }
    
    init(userNotificationService: UserNotificationService) {
        self.userNotificationService = userNotificationService
        
        selectedDays = BehaviorRelay(value: UserDefaults.selectedAlarmDays)
        alarmDate = BehaviorRelay(value: UserDefaults.alarmDate)
        isAlarmOn = BehaviorRelay(value: UserDefaults.isAlarmOn)
        
        isAlarmOn
            .subscribe(onNext: { [weak self] isOn in
                guard let self else { return }
                if isOn {
                    self.userNotificationService.requestAuthorization()
                        .subscribe(onError: { [weak self] _ in
                            guard let self else { return }
                            self.isAlarmOn.accept(false)
                        }).disposed(by: self.disposeBag)
                }
            }).disposed(by: disposeBag)
    }
    
    func registAlarm(_ date: Date) -> Observable<Void> {
        UserDefaults.selectedAlarmDays = selectedDays.value
        UserDefaults.alarmDate = date
        UserDefaults.isAlarmOn = true
        
        return userNotificationService
            .requestAuthorization()
            .withLatestFrom(userNotificationService.createNotification(time: date, daysOfWeek: selectedDays.value))
    }
}

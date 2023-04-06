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

final class DefaultAlarmSettingUseCase: AlarmSettingUseCase {
    private let userNotificationService: UserNotificationService
    
    private var disposeBag = DisposeBag()
    var selectedDays: BehaviorRelay<[Bool]>
    var alarmDate: BehaviorRelay<Date>
    var isAuthorized = PublishRelay<Bool>()
    
    var selectedDaysDescription: String {
        let koreanDays = ["월", "화", "수", "목", "금", "토", "일"]
        let days = selectedDays.value
            .enumerated()
            .map { $0.element ? koreanDays[$0.offset] : "" }
            .joined()
        
        switch days {
        case "":
            return "안 함"
        case "월화수목금토일":
            return "매일"
        case "토일":
            return "주말"
        case "월화수목금":
            return "주중"
        default:
            return days.map { String($0) }.joined(separator: " ")
        }
    }
    
    init(userNotificationService: UserNotificationService) {
        self.userNotificationService = userNotificationService
        
        selectedDays = BehaviorRelay(value: UserDefaults.selectedAlarmDays)
        alarmDate = BehaviorRelay(value: UserDefaults.alarmDate)
    }
    
    func checkInitialyIsAlarmOn() -> Observable<Bool> {
        Observable.create { [weak self] observer in
            guard let self else { return Disposables.create() }
            if UserDefaults.isAlarmOn {
                self.userNotificationService.checkAlertSettings()
                    .subscribe(onNext: { allow in
                        observer.onNext(allow)
                    })
                    .disposed(by: self.disposeBag)
            } else {
                observer.onNext(false)
            }
            
            return Disposables.create()
        }
    }
    
    func registAlarm(_ date: Date) -> Observable<Bool> {
        UserDefaults.selectedAlarmDays = selectedDays.value
        UserDefaults.alarmDate = date
        UserDefaults.isAlarmOn = true
        
        return userNotificationService.createNotification(time: date, daysOfWeek: selectedDays.value)
    }
    
    func onAlarm() -> Observable<Bool> {
        Observable.create { [weak self] observer in
            guard let self else { return Disposables.create() }
            self.userNotificationService.createNotification(time: UserDefaults.alarmDate,
                                                            daysOfWeek: UserDefaults.selectedAlarmDays)
            .subscribe(onNext: { allow in
                if allow {
                    UserDefaults.isAlarmOn = true
                }
                observer.onNext(allow)
            })
            .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    func offAlarm() {
        UserDefaults.isAlarmOn = false
        userNotificationService.removeAllNotifications()
    }
}

//
//  AlrarmSettingUseCase.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/11.
//

import Foundation
import RxSwift
import RxRelay

protocol AlarmSettingUseCase {
    var selectedDays: BehaviorRelay<[Bool]> { get set }
    var alarmDate: BehaviorRelay<Date> { get set }
    var isAuthorized: PublishRelay<Bool> { get set }
    var selectedDaysDescription: String { get }
    func checkInitialyIsAlarmOn() -> Observable<Bool>
    func registAlarm(_ date: Date) -> Observable<Bool>
    func onAlarm() -> Observable<Bool>
    func offAlarm()
}

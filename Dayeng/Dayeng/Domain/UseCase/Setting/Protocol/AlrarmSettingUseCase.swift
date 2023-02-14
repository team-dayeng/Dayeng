//
//  AlrarmSettingUseCase.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/11.
//

import Foundation
import RxSwift
import RxRelay

protocol AlrarmSettingUseCase {
    var selectedDays: BehaviorRelay<[Bool]> { get set }
    var alarmDate: BehaviorRelay<Date> { get set }
    var initialyIsAlarmOn: BehaviorRelay<Bool> { get set }
    var isAuthorized: PublishRelay<Bool> { get set }
    var selectedDaysDescription: String { get }
    func registAlarm(_ date: Date) -> Observable<Void>
    func onAlarm() -> Observable<Void>
    func offAlarm()
}

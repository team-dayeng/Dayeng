//
//  UserNotificationService.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/12.
//

import Foundation
import RxSwift

protocol UserNotificationService {
    func checkAlertSettings() -> Observable<Bool>
    func createNotification(time: Date, daysOfWeek: [Bool]) -> Observable<Bool>
    func removeAllNotifications()
}

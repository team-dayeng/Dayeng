//
//  UserNotificationService.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/12.
//

import Foundation
import RxSwift

protocol UserNotificationService {
    func requestAuthorization() -> Observable<Void>
    func createNotification(time: Date, daysOfWeek: [Bool]) -> Observable<Void>
    func removeAllNotifications()
}

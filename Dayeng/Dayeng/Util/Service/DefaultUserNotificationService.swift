//
//  DefaultUserNotificationService.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/12.
//

import Foundation
import UserNotifications
import RxSwift

final class DefaultUserNotificationService: UserNotificationService {
    enum UserNotificationError: Error {
        case notAuthorized
        case unknownError
    }
    
    private let disposeBag = DisposeBag()
    
    func checkAlertSettings() -> Observable<Bool> {
        Observable.create { observer in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                if settings.authorizationStatus == .denied || settings.alertSetting == .disabled {
                    return observer.onNext(false)
                }
                return observer.onNext(true)
            }
            
            return Disposables.create()
        }
    }

    func createNotification(time: Date, daysOfWeek: [Bool]) -> Observable<Bool> {
        removeAllNotifications()
        let content = UNMutableNotificationContent()
        content.title = "데잉을 쓸 시간이에요!"
        content.body = "오늘의 일기를 작성해보아요"
        return checkAlertSettings()
            .flatMap { [weak self] allow in
                guard let self else { return Observable.just(false) }
                if !allow {
                    return Observable.just(false)
                }
                let createdNotificationResults = daysOfWeek.enumerated().filter {$0.element}.map { (index, _) in
                    let indexToWeekDay = ((index+1)%7)+1
                    return self.createNotification(time: time, weekDay: indexToWeekDay, content: content)
                }
                
                if createdNotificationResults.isEmpty {
                    return Observable.just(true)
                }
                
                return Observable.zip(createdNotificationResults)
                    .map { results in
                        !results.contains(false)
                    }
            }
    }
    
    func removeAllNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            UNUserNotificationCenter
                .current()
                .removePendingNotificationRequests(withIdentifiers: requests.map { $0.identifier })
        }
    }
    
    private func createNotification(time: Date, weekDay: Int, content: UNNotificationContent) -> Observable<Bool> {
        Observable<Bool>.create { observer in
            var dateComponets = DateComponents()
            dateComponets.hour = Calendar.current.component(.hour, from: time)
            dateComponets.minute = Calendar.current.component(.minute, from: time)
            dateComponets.weekday = weekDay
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponets, repeats: true)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                if error != nil {
                    return observer.onNext(false)
                }
                return observer.onNext(true)
            })
            return Disposables.create()
        }
    }
}

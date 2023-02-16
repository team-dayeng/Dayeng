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
    func requestAuthorization() -> Observable<Void> {
        Observable<Void>.create { observer in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { (allow, error) in
                if let error = error {
                    observer.onError(error)
                }
                if !allow {
                    observer.onError(UserNotificationError.notAuthorized)
                }
                observer.onNext(())
            }
            return Disposables.create()
        }
    }

    func createNotification(time: Date, daysOfWeek: [Bool]) -> Observable<Void> {
        removeAllNotifications()
        let content = UNMutableNotificationContent()
        content.title = "데잉을 쓸 시간이에요!"
        content.body = "오늘의 일기를 작성해보아요"
        
        let createdNotificationResults = daysOfWeek.enumerated().filter {$0.element}.map { (index, _) in
            let indexToWeekDay = ((index+1)%7)+1
            return createNotification(time: time, weekDay: indexToWeekDay, content: content)
        }
        
        return Observable.zip(createdNotificationResults)
            .flatMapLatest { _ in
                Observable.create { observer in
                    observer.onNext(())
                    return Disposables.create()
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
    
    private func createNotification(time: Date, weekDay: Int, content: UNNotificationContent) -> Observable<Void> {
        Observable<Void>.create { observer in
            let center = UNUserNotificationCenter.current()
            center.getNotificationSettings { settings in
                guard settings.authorizationStatus == .authorized ||
                        settings.authorizationStatus == .provisional,
                      settings.alertSetting == .enabled else { return }
                
                var dateComponets = DateComponents()
                dateComponets.hour = Calendar.current.component(.hour, from: time)
                dateComponets.minute = Calendar.current.component(.minute, from: time)
                dateComponets.weekday = weekDay
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponets, repeats: true)
                
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                    if let error = error {
                        return observer.onError(error)
                    }
                    return observer.onNext(())
                })
            }
            return Disposables.create()
        }
    }
}

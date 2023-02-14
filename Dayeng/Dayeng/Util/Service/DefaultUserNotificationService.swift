//
//  DefaultUserNotificationService.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/12.
//

import Foundation
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
        content.title = "일기 쓸 시간"
        content.body = "ㅆㅓ라"
        
        let this = daysOfWeek.enumerated().filter {$0.element}.map { (index, _) in
            let indexToWeekDay = ((index+1)%7)+1
            return createNotification(time: time, weekDay: indexToWeekDay, content: content)
        }
        
        return Observable.zip(this)
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

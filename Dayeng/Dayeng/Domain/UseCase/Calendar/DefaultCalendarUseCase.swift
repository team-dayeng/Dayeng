//
//  DefaultCalendarUseCase.swift
//  Dayeng
//
//  Created by 배남석 on 2023/03/04.
//

import Foundation
import RxSwift

final class DefaultCalendarUseCase: CalendarUseCase {
    // MARK: - Properties
    private let userRepository: UserRepository
    private let ownerType: OwnerType
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycles
    init(userRepository: UserRepository, ownerType: OwnerType) {
        self.userRepository = userRepository
        self.ownerType = ownerType
    }
    
    // MARK: - Helpers
    func fetchOwnerType() -> OwnerType {
        return ownerType
    }
    
    func fetchAnswers() -> Observable<[Answer?]> {
        var answers = [Answer?]()
        switch ownerType {
        case .mine:
            if let user = DayengDefaults.shared.user {
                answers = user.answers
            } else {
                return Observable.error(UserError.notExistCurrentUser)
            }
        case .friend(let user):
            answers = user.answers
        }
    
        while DayengDefaults.shared.questions.count > answers.count {
            answers.append(nil)
        }
        return Observable.just(answers)
    }
    
    func fetchCurrentIndex() -> Int {
        switch ownerType {
        case .mine:
            if let user = DayengDefaults.shared.user {
                if user.answers.last?.date == Date().convertToString(format: "yyyy.MM.dd.E") {
                    return user.currentIndex - 1
                }
                return user.currentIndex
            } else {
                return -1
            }
        case .friend(let user):
            print(user.name, user.answers.last?.date)
            if user.answers.last?.date == Date().convertToString(format: "yyyy.MM.dd.E") {
                return user.currentIndex - 1
            }
            return user.currentIndex
        }
    }
}

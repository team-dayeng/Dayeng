//
//  DefaultMainUseCase.swift
//  Dayeng
//
//  Created by 조승기 on 2023/03/03.
//

import Foundation
import RxSwift

final class DefaultMainUseCase: MainUseCase {
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    enum MainUseCaseError: Error {
        case noUserError
    }
    
    func fetchData() -> Observable<[(Question, Answer?)]> {
        Observable.zip(fetchQuestions(), fetchAnswers())
            .map { questions, answers in
                questions.enumerated().map { (index, question) in
                    let answer = answers.count > index ? answers[index] : nil
                    return (question, answer)
                }
            }
    }
    
    func isBlurLastCell() -> Observable<Bool> {
        guard let user = DayengDefaults.shared.user else {
            return Observable.error(MainUseCaseError.noUserError)
        }
        let today = Date().convertToString(format: "yyyy.MM.dd.E")
        
        let isAnswered = user.answers.last?.date == today
        let isUsedBonus = user.bonusQuestionDate?.isToday ?? false
        let isAnsweredBonus = user.answers.filter { $0.date == today }.count >= 2
        
        var isBlur = true
        
        if isAnswered {
            if isUsedBonus {
                isBlur = isAnsweredBonus
            } else {
                isBlur = true
            }
        } else {
            isBlur = false
        }
        
        return Observable.just(isBlur)
    }
    
    func canGetBonus() -> Observable<Bool> {
        guard let user = DayengDefaults.shared.user else {
            return Observable.error(MainUseCaseError.noUserError)
        }
        let today = Date().convertToString(format: "yyyy.MM.dd.E")
        
        let isAnswered = user.answers.last?.date == today
        let isUsedBonus = user.bonusQuestionDate?.isToday ?? false
        let isAnsweredBonus = user.answers.filter { $0.date == today }.count >= 2
        
        var canGetBonus = false
        
        if isAnswered {
            canGetBonus = !isAnsweredBonus
        }
        
        return Observable.just(canGetBonus)
    }
    
    func getBonusQuestion() -> Observable<Void> {
        guard let user = DayengDefaults.shared.user else {
            return Observable.error(MainUseCaseError.noUserError)
        }
        DayengDefaults.shared.getBonusQuestion()
        return userRepository.uploadUser(user: user)
    }
    
    private func fetchQuestions() -> Observable<[Question]> {
        Observable.of(DayengDefaults.shared.questions)
            .map { questions in
                guard let user = DayengDefaults.shared.user,
                      questions.count >= user.currentIndex+1 else { return [] }
                return questions[0..<user.currentIndex+1].map { $0 }
            }
    }
    
    private func fetchAnswers() -> Observable<[Answer]> {
        Observable.just(DayengDefaults.shared.user?.answers ?? [])
    }
}

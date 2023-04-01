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

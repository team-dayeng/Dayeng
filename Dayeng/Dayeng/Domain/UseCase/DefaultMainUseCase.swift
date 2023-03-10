//
//  DefaultMainUseCase.swift
//  Dayeng
//
//  Created by 조승기 on 2023/03/03.
//

import Foundation
import RxSwift

final class DefaultMainUseCase: MainUseCase {
    enum MainUseCaseError: Error {
        case noUserError
    }
    
    func fetchData() -> Observable<[(Question, Answer?)]> {
        Observable.zip(fetchQuestions(), fetchAnswers())
            .map { questions, answers in
                questions.enumerated().map {
                    ($0.element, (answers.count > $0.offset ? answers[$0.offset] : nil))
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
        Observable.create { observer in
            guard let user = DayengDefaults.shared.user else {
                observer.onNext([])
                return Disposables.create()
            }
            observer.onNext(user.answers)
            return Disposables.create()
        }
    }
}

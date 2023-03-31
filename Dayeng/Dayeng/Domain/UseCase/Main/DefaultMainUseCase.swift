//
//  DefaultMainUseCase.swift
//  Dayeng
//
//  Created by 배남석 on 2023/03/31.
//

import Foundation
import RxSwift

final class DefaultMainUseCase: MainUseCase {
    // MARK: - Dependency
    private let userRepository: UserRepository
    private let questionRepository: QuestionRepository
    private let disposeBag = DisposeBag()
    
    // MARK: - LifeCycle
    init(userRepository: UserRepository, questionRepository: QuestionRepository) {
        self.userRepository = userRepository
        self.questionRepository = questionRepository
    }
    
    // MARK: - Helper
    
    func fetchQuestions() -> Observable<Void> {
        Observable.create { [weak self] observer in
            guard let self else { return Disposables.create() }
            
            if DayengDefaults.shared.questions.count == 0 {
                self.questionRepository.fetchAll()
                    .map { questions in
                        DayengDefaults.shared.questions = questions
                    }
                    .bind(to: observer)
                    .disposed(by: self.disposeBag)
            } else {
                observer.onNext(())
            }
            
            return Disposables.create()
        }

    }
    
    func fetchUser() -> Observable<Void> {
        Observable.create { [weak self] observer in
            guard let self, let userID = UserDefaults.userID else { return Disposables.create() }
            if DayengDefaults.shared.user != nil {
                observer.onNext(())
            } else {
                self.userRepository.fetchUser(userID: userID)
                    .map { user in
                        DayengDefaults.shared.user = user
                    }
                    .bind(to: observer)
                    .disposed(by: self.disposeBag)
            }
            
            return Disposables.create()
        }

    }
}

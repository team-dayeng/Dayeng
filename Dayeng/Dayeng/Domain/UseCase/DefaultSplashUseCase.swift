//
//  DefaultSplashUseCase.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/11.
//

import Foundation
import RxSwift
import FirebaseAuth

final class DefaultSplashUseCase: SplashUseCase {
    
    // MARK: - Dependencies
    private let userRepository: UserRepository
    private let questionRepository: QuestionRepository
    
    // MARK: - LifeCycles
    init(userRepository: UserRepository, questionRepository: QuestionRepository) {
        self.userRepository = userRepository
        self.questionRepository = questionRepository
    }
    
    // MARK: - Helpers
    func isAvailableAutoLogin() -> Bool {
        Auth.auth().currentUser != nil
    }
    
    func fetchQuestions() -> Observable<Void> {
        questionRepository.fetchAll()
            .map { questions in
                DayengDefaults.shared.questions = questions
            }
    }
    
    func fetchUser(userID: String) -> Observable<Void> {
        userRepository.fetchUser(userID: userID)
            .map { user in
                DayengDefaults.shared.user = user
            }
    }
}

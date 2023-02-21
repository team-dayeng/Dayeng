//
//  DefaultSplashUseCase.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/11.
//

import Foundation
import RxSwift

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
    func fetchQuestions() -> Observable<[Question]> {
        questionRepository.fetchAll()
    }
    
    func fetchUser(userID: String) -> Observable<User> {
        userRepository.fetchUser(userID: userID)
    }
    
}

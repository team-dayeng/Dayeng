//
//  DefaultSplashUseCase.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/11.
//

import Foundation
import RxSwift
import AuthenticationServices

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
    func isAvailableAppleLogin() -> Observable<Bool> {
        Observable.create { observer in
            guard let userID = UserDefaults.appleID else {
                observer.onNext(false)
                return Disposables.create()
            }

            ASAuthorizationAppleIDProvider()
                .getCredentialState(forUserID: userID) { (credentialState, _) in
                    if credentialState != .authorized {
                        observer.onNext(false)
                        return
                    }
                    observer.onNext(true)
                }
            return Disposables.create()
        }
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

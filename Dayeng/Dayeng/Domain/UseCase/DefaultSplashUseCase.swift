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
    private let appleLoginService: AppleLoginService
    private let kakaoLoginService: KakaoLoginService
    private let disposeBag = DisposeBag()
    
    // MARK: - LifeCycles
    init(
        userRepository: UserRepository,
        questionRepository: QuestionRepository,
        appleLoginService: AppleLoginService,
        kakaoLoginService: KakaoLoginService
    ) {
        self.userRepository = userRepository
        self.questionRepository = questionRepository
        self.appleLoginService = appleLoginService
        self.kakaoLoginService = kakaoLoginService
    }
    
    // MARK: - Helpers
    func tryAutoLogin() -> Observable<Bool> {
        Observable.create { [weak self] observer in
            guard let self,
                  Auth.auth().currentUser != nil else {
                observer.onNext(false)
                return Disposables.create()
            }
            
            if UserDefaults.appleID == nil {
                self.kakaoLoginService.isLoggedIn()
                    .do(onNext: { result in
                        if !result { try? Auth.auth().signOut() }
                    })
                    .bind(to: observer)
                    .disposed(by: self.disposeBag)
            } else {
                self.appleLoginService.isLoggedIn()
                    .do(onNext: { result in
                        if !result { try? Auth.auth().signOut() }
                    })
                    .bind(to: observer)
                    .disposed(by: self.disposeBag)
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

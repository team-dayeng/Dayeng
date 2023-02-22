//
//  SplashViewModel.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/11.
//

import Foundation
import RxSwift
import RxRelay
import AuthenticationServices

final class SplashViewModel {
    // MARK: - Input
    struct Input {
        let animationDidStarted: Observable<Void>
    }
    
    // MARK: - Output
    struct Output {
        
    }
    
    // MARK: - Properites
    private var disposeBag = DisposeBag()
    var dataDidLoaded = PublishRelay<Void>()
    var loginStatus = PublishRelay<Bool>()
    
    // MARK: - Dependency
    private let useCase: SplashUseCase
    
    // MARK: - Lifecycles
    init(useCase: SplashUseCase) {
        self.useCase = useCase
    }
    
    // MARK: - Helpers
    func transform(input: Input) -> Output {
        input.animationDidStarted
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                // 애플 로그인 여부 확인
                if let userID = UserDefaults.standard.string(forKey: "appleID") {
                    let appleIDProvider = ASAuthorizationAppleIDProvider()
                    appleIDProvider.getCredentialState(forUserID: userID) { (credentialState, error) in
                        if error != nil {
                            // case .revoked, .notFound에도 error != nil이 되어 여기로 옴
                            self.loginStatus.accept(false)
                            return
                        }

                        switch credentialState {
                        case .authorized:
                            print("ID 연동 O")
                            // TODO: 파베 자동로그인
                            
                            // user 데이터 fetch
                            guard let firebaseUserID = UserDefaults.standard.string(forKey: "uid") else {
                                self.loginStatus.accept(false)
                                return
                            }
                            Observable.zip(
                                self.useCase.fetchQuestions(),
                                self.useCase.fetchUser(userID: firebaseUserID)
                            )
                            .subscribe(onNext: { [weak self] (questions, user) in
                                guard let self else { return }
                                DayengDefaults.shared.questions = questions
                                DayengDefaults.shared.user = user
                                
                                self.loginStatus.accept(true)
                                self.dataDidLoaded.accept(())
                            }, onError: {
                                // TODO: error handling
                                print($0)
                                self.loginStatus.accept(false)
                            })
                            .disposed(by: self.disposeBag)
                        case .revoked, .notFound:
                            print("ID가 연동되어 있지 않거나 ID를 찾을 수 없음")
                            self.loginStatus.accept(false)
                        default:
                            break
                        }
                    }
                } else {
                    self.loginStatus.accept(false)
                }
                
                // TODO: 딥링크 확인
            
            })
            .disposed(by: disposeBag)
        
        return Output()
    }
}

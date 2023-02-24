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
    var loginStatus = PublishSubject<Bool>()
    var dataDidLoad = PublishSubject<Void>()
    
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
                self.useCase.isAvailableAppleLogin()
                    .do(onNext: { [weak self] isAvailable in
                        guard let self else { return }
                        if isAvailable,
                           let firebaseUserID = UserDefaults.userID {
                            print("ID 연동 O")
                            
                            Observable.zip(
                                self.useCase.fetchQuestions(),
                                self.useCase.fetchUser(userID: firebaseUserID)
                            )
                            .map { _ in }
                            .bind(to: self.dataDidLoad)
                            .disposed(by: self.disposeBag)
                        } else {
                            print("ID가 연동되어 있지 않거나 ID를 찾을 수 없음")
                            self.fetchQuestions()
                        }
                    })
                    .bind(to: self.loginStatus)
                    .disposed(by: self.disposeBag)
                
                // TODO: 딥링크 확인
                
            })
            .disposed(by: disposeBag)
        
        return Output()
    }
    
    private func fetchQuestions() {
        useCase.fetchQuestions()
            .bind(to: self.dataDidLoad)
            .disposed(by: disposeBag)
    }
}

//
//  SplashViewModel.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/11.
//

import Foundation
import RxSwift
import RxRelay

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

                self.useCase.tryAutoLogin()
                    .subscribe(onNext: { [weak self] result in
                        guard let self else { return }
                        if result, let firebaseUserID = UserDefaults.userID {
                            self.successAutoLogin(userID: firebaseUserID)
                        } else {
                            self.failAutoLogin()
                        }
                    }, onError: { [weak self] _ in
                        guard let self else { return }
                        self.failAutoLogin()
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        return Output()
    }
    
    private func successAutoLogin(userID: String) {
        print("ID 연동 O")
        loginStatus.onNext(true)
        
        Observable.zip(
            useCase.fetchQuestions(),
            useCase.fetchUser(userID: userID)
        )
        .map { _ in }
        .bind(to: dataDidLoad)
        .disposed(by: disposeBag)
    }
    
    private func failAutoLogin() {
        print("ID 연동 X")
        loginStatus.onNext(false)
        
        useCase.fetchQuestions()
            .bind(to: dataDidLoad)
            .disposed(by: disposeBag)
    }
}

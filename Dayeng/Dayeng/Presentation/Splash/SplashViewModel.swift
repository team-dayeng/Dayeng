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

                if self.useCase.isAvailableAutoLogin(),
                   let firebaseUserID = UserDefaults.userID {
                    print("ID 연동 O")
                    self.loginStatus.onNext(true)
                    
                    Observable.zip(
                        self.useCase.fetchQuestions(),
                        self.useCase.fetchUser(userID: firebaseUserID)
                    )
                    .map { _ in }
                    .bind(to: self.dataDidLoad)
                    .disposed(by: self.disposeBag)
                    
                } else {
                    print("ID가 연동되어 있지 않거나 ID를 찾을 수 없음")
                    self.loginStatus.onNext(false)
                    self.fetchQuestions()
                }
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

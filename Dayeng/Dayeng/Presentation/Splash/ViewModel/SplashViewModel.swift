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
                        self.loginStatus.onNext(result)
                        self.loginStatus.onCompleted()
                    }, onError: { [weak self] _ in
                        guard let self else { return }
                        self.loginStatus.onNext(false)
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        return Output()
    }
}

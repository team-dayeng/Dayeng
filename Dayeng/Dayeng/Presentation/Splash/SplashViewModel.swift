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
    var dataDidLoaded = PublishRelay<Void>()
    
    // MARK: - Dependency
    private let useCase: SplashUseCase
	private weak var coordinator: AppCoordinator?
    
    // MARK: - Lifecycles
    init(useCase: SplashUseCase) {
        self.useCase = useCase
    }
    
    // MARK: - Helpers
    func transform(input: Input) -> Output {
        input.animationDidStarted
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                #warning("userID 변경")
                Observable.zip(
                    self.useCase.fetchQuestions(),
                    self.useCase.fetchUser(userID: "ongeee")
                )
                .subscribe(onNext: { [weak self] (_, _) in
                    guard let self else { return }
                    self.dataDidLoaded.accept(())
                }, onError: {
                    print($0)
                })
                .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        return Output()
    }
}

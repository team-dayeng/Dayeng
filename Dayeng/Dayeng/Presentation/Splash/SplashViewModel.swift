//
//  SplashViewModel.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/11.
//

import Foundation
import RxSwift

final class SplashViewModel {
    // MARK: - Input
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    // MARK: - Output
    struct Output {
        
    }
    
    // MARK: - Properites
    private var disposeBag = DisposeBag()
    
    // MARK: - Dependency
    private let useCase: SplashUseCase
    
    // MARK: - Lifecycles
    init(useCase: SplashUseCase) {
        self.useCase = useCase
    }
    
    // MARK: - Helpers
    func transform(input: Input) -> Output {
        input.viewDidLoad
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                #warning("userID 변경")
                Observable.zip(
                    self.useCase.fetchQuestions(),
                    self.useCase.fetchUser(userID: "ongeee")
                )
                .subscribe(onNext: { (_, _) in
                    // 화면전환
                    
                }, onError: {
                    print($0)
                })
                .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        return Output()
    }
}

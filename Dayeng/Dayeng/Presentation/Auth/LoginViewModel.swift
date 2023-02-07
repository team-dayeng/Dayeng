//
//  LoginViewModel.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/03.
//

import Foundation

import AuthenticationServices
import RxSwift

final class LoginViewModel {
    // MARK: - Input
    struct Input {
        var appleLoginButtonDidTap: Observable<Void>
        var kakaoLoginButtonDidTap: Observable<Void>
    }
    
    // MARK: - Output
    struct Output {
        
    }
    
    // MARK: - Dependency
    private let disposeBag = DisposeBag()
    private weak var coordinator: AppCoordinator?
    
    // MARK: - Lifecycles
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }
}
    
extension LoginViewModel {
    
    // MARK: - Helpers
    func transform(input: Input) -> Output {
        
        input.appleLoginButtonDidTap.subscribe(onNext: {

        })
        .disposed(by: disposeBag)
        
        return Output()
    }
}

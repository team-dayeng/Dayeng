//
//  LoginViewModel.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/03.
//

import Foundation

import RxSwift
import RxCocoa

final class LoginViewModel {
    // MARK: - Input
    struct Input {
        var appleLoginButtonDidTap: Observable<Void>
        var kakaoLoginButtonDidTap: Observable<Void>
    }
    
    // MARK: - Output
    struct Output {
    }
    
    // MARK: - Properties
    var currentNonce: String?
    var loginResult = PublishSubject<Void>()
    
    // MARK: - Dependency
    private let useCase: LoginUseCase
    var disposeBag = DisposeBag()
    
    // MARK: - Lifecycles
    init(useCase: LoginUseCase) {
        self.useCase = useCase
    }
}
    
extension LoginViewModel {
    
    // MARK: - Helpers
    func transform(input: Input) -> Output {
        input.appleLoginButtonDidTap
            .withUnretained(self)
            .flatMap { (owner, _) in
                owner.useCase.appleSignIn()
            }
            .bind(to: loginResult)
            .disposed(by: disposeBag)
        
        input.kakaoLoginButtonDidTap
            .withUnretained(self)
            .flatMap { (owner, _) in
                owner.useCase.kakaoSignIn()
            }
            .bind(to: loginResult)
            .disposed(by: disposeBag)
        
        return Output()
    }
}

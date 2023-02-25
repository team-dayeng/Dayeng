//
//  LoginViewModel.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/03.
//

import Foundation

import RxSwift
import RxCocoa
import AuthenticationServices
import CryptoKit
import FirebaseAuth

final class LoginViewModel {
    
    var disposeBag = DisposeBag()
    
    // MARK: - Input
    struct Input {
        var appleLoginButtonDidTap: Observable<Void>
        var kakaoLoginButtonDidTap: Observable<Void>
    }
    
    // MARK: - Output
    struct Output {
        var loginResult = PublishRelay<Void>()
    }
    
    // MARK: - Properties
    var currentNonce: String?
    var loginResult = PublishRelay<Void>()
    
    // MARK: - Dependency
    private let useCase: LoginUseCase
    
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
        
        return Output(loginResult: loginResult)
    }
}

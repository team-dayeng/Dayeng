//
//  LoginViewModel.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/03.
//

import Foundation

import AuthenticationServices
import RxSwift

class LoginViewModel {
    
    var disposeBag = DisposeBag()
    
    // MARK: - Input
    struct Input {
        var appleLoginButtonDidTap: Observable<Void>
        var kakaoLoginButtonDidTap: Observable<Void>
    }
    
    // MARK: - Output
    struct Output {
        
    }
    
    // MARK: - Dependency
    
    // MARK: - Lifecycles
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

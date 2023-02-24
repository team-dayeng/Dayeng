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
        var loginFailure = PublishRelay<Void>()
    }
    
    // MARK: - Properties
    var currentNonce: String?
    var loginSuccess = PublishRelay<Void>()
    var loginFailure = PublishRelay<Void>()
    
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
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.appleSignIn()
            })
            .disposed(by: disposeBag)
        
        return Output(loginFailure: loginFailure)
    }
    
    private func appleSignIn() {
        AppleLoginService.shared.signIn()
            .subscribe(onNext: { [weak self] (credential, userName) in
                guard let self else { return }
                self.firebaseAuthSignIn(credential: credential, userName: userName)
            }, onError: { [weak self] error in
                print(error.localizedDescription)
                UserDefaults.standard.removeObject(forKey: "appleID")
                
                guard let self else { return }
                self.loginFailure.accept(())
            })
            .disposed(by: disposeBag)
    }
    
    private func firebaseAuthSignIn(credential: OAuthCredential, userName: String) {
        useCase.signIn(credential: credential, userName: userName)
            .subscribe(onNext: { [weak self] user in
                guard let self else { return }
                
                print("login success")
                
                UserDefaults.standard.set(user.uid, forKey: "uid")
                
                DayengDefaults.shared.questions = []
                DayengDefaults.shared.user = user
                
                self.loginSuccess.accept(())
            }, onError: { [weak self] _ in
                guard let self else { return }
                self.loginFailure.accept(())
            })
            .disposed(by: disposeBag)
    }
}

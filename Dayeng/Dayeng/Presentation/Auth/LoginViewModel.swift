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
    
    enum LoginError: Error {
        case notExistNonce
        case cannotFetchIdToken
        case tokenSerializationFail
        case cannotFetchUserName
        case appleLoginFailure
    }
    
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
        input.appleLoginButtonDidTap.subscribe(onNext: { [weak self] in
            guard let self else { return }
            self.startSignInWithAppleFlow()
        })
        .disposed(by: disposeBag)
        
        return Output(loginFailure: loginFailure)
    }
    
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce

        ASAuthorizationAppleIDProvider().rx.login(
            scope: [.fullName, .email],
            nonce: sha256(nonce)
        )
        .subscribe(onNext: { [weak self] authorization in
            guard let self else { return }
            
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = self.currentNonce else {
                    print(LoginError.notExistNonce.localizedDescription)
                    return
                }
                
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print(LoginError.cannotFetchIdToken.localizedDescription)
                    return
                }
                
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print(LoginError.tokenSerializationFail.localizedDescription)
                    return
                }
                
                guard let familyName = appleIDCredential.fullName?.familyName,
                      let givenName = appleIDCredential.fullName?.givenName else {
                    print(LoginError.cannotFetchUserName.localizedDescription)
                    return
                }
                
                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: nonce)
                let fullName = familyName + givenName
                
                // TODO: 로그인할동안 인디케이터 뷰
                self.useCase.signIn(credential: credential, userName: fullName)
                    .subscribe(onNext: { user in
                        print("login success")
                        
                        UserDefaults.standard.set(appleIDCredential.user, forKey: "appleID")
                        UserDefaults.standard.set(user.uid, forKey: "uid")
                        
                        DayengDefaults.shared.questions = []
                        DayengDefaults.shared.user = user
                        
                        // TODO: 만약 애플 로그인 - 로그아웃 후 재로그인 한다면 ?? 즉, 퀘스쳔 데이터가 있는 상태라면 ?? 
                        self.loginSuccess.accept(())
                    }, onError: { _ in
                        self.loginFailure.accept(())
                    })
                    .disposed(by: self.disposeBag)
            }
        }, onError: { [weak self] _ in
            guard let self else { return }
            print(LoginError.appleLoginFailure.localizedDescription)
            self.loginFailure.accept(())
        })
        .disposed(by: disposeBag)
    }
}

extension LoginViewModel {
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

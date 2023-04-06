//
//  DefaultAppleLoginService.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/24.
//

import Foundation
import RxSwift
import AuthenticationServices
import CryptoKit
import FirebaseAuth

final class DefaultAppleLoginService: AppleLoginService {
    
    var currentNonce: String?
    private let disposeBag = DisposeBag()
    
    enum AppleLoginError: Error {
        case notExistSelf
        case cannotCreateNonce
        case cannotFetchIdToken
        case tokenSerializationFail
        case cannotFetchUserName
        case credentialTypeCastingError
        case notAppleLoggedIn
    }
    
    func signIn() -> Observable<(credential: OAuthCredential, name: String?)> {
        guard let nonce = randomNonceString() else {
            return Observable.error(AppleLoginError.cannotCreateNonce)
        }
        currentNonce = nonce
        
        return ASAuthorizationAppleIDProvider().rx.login(
            scope: [.fullName],
            nonce: sha256(nonce)
        )
        .map { [weak self] authorization in
            guard let self else {
                throw AppleLoginError.notExistSelf
            }
            
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = self.currentNonce else {
                    throw AppleLoginError.cannotCreateNonce
                }
                
                guard let appleIDToken = appleIDCredential.identityToken else {
                    throw AppleLoginError.cannotFetchIdToken
                }
                
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    throw AppleLoginError.tokenSerializationFail
                }
                
                let fullName = (appleIDCredential.fullName?.familyName ?? "")
                                + (appleIDCredential.fullName?.givenName ?? "")
                let userName = fullName != "" ? fullName : nil

                UserDefaults.appleID = appleIDCredential.user
                
                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: nonce)
                
                return (credential, userName)
            }
            throw AppleLoginError.credentialTypeCastingError
        }
    }
    
    func isLoggedIn() -> Observable<Bool> {
        Observable.create { observer in
            guard let userID = UserDefaults.appleID else {
                observer.onNext(false)
                return Disposables.create()
            }

            ASAuthorizationAppleIDProvider()
                .getCredentialState(forUserID: userID) { (credentialState, _) in
                    if credentialState != .authorized {
                        observer.onNext(false)
                        return
                    }
                    observer.onNext(true)
                }
            return Disposables.create()
        }
    }
    
    func reauthenticate() -> Observable<OAuthCredential> {
        Observable.create { [weak self] observer in
            guard let self else {
                observer.onError(AppleLoginError.notExistSelf)
                return Disposables.create()
            }
            self.isLoggedIn()
                .subscribe(onNext: { [weak self] result in
                    guard let self else {
                        observer.onError(AppleLoginError.notExistSelf)
                        return
                    }
                    if result {
                        DispatchQueue.main.async {
                            self.signIn()
                                .map { $0.credential }
                                .bind(to: observer)
                                .disposed(by: self.disposeBag)
                        }
                    } else {
                        observer.onError(AppleLoginError.notAppleLoggedIn)
                    }
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func signOut() {
        // idtokenString 저장해서 시도해ㅗ보고, 갱신 필요하면 사인인 후 로그아웃
        UserDefaults.appleID = nil
    }
    
    func withdrawal() {
        UserDefaults.isAppleSignedIn = false
        UserDefaults.appleID = nil
    }
}

extension DefaultAppleLoginService {
    
    private func randomNonceString(length: Int = 32) -> String? {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        var randoms = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randoms.count, &randoms)
        if errorCode != errSecSuccess {
            return nil
        }
            
        return String(randoms.map { random in
            charset[Int(random)%charset.count]
        })
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

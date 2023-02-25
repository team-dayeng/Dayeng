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

final class AppleLoginService {
    
    static let shared = AppleLoginService()
    
    var currentNonce: String?
    
    private init() {}
    
    enum AppleLoginError: Error {
        case notExistSelf
        case notExistNonce
        case cannotFetchIdToken
        case tokenSerializationFail
        case cannotFetchUserName
        case credentialTypeCastingError
    }
    
    func signIn() -> Observable<(credential: OAuthCredential, name: String)> {
        guard let nonce = randomNonceString() else {
            return Observable.error(AppleLoginError.notExistNonce)
        }
        currentNonce = nonce
        
        return ASAuthorizationAppleIDProvider().rx.login(
            scope: [.fullName],
            nonce: sha256(nonce)
        )
        .map { [weak self] authorization in
            guard let self else { throw AppleLoginError.notExistSelf }
            
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = self.currentNonce else {
                    throw AppleLoginError.notExistNonce
                }
                
                guard let appleIDToken = appleIDCredential.identityToken else {
                    throw AppleLoginError.cannotFetchIdToken
                }
                
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    throw AppleLoginError.tokenSerializationFail
                }
                
                let familyName = appleIDCredential.fullName?.familyName
                let givenName = appleIDCredential.fullName?.givenName
                
                guard let fullName = (familyName != nil && givenName != nil) ?
                        (familyName! + givenName!) : UserDefaults.userName else {
                    throw AppleLoginError.cannotFetchUserName
                }
                
                UserDefaults.appleID = appleIDCredential.user
                UserDefaults.userName = fullName
                
                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: nonce)
                
                return (credential, fullName)
            }
            throw AppleLoginError.credentialTypeCastingError
        }
    }
    
}

extension AppleLoginService {
    
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

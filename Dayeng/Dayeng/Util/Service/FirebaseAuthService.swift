//
//  FirebaseAuthService.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/04/02.
//

import Foundation
import RxSwift
import FirebaseAuth

protocol FirebaseAuthService {
    /// sign in with apple 시 사용
    func signUp(with credential: OAuthCredential) -> Single<String>
    /// sign in with kakao 시 사용
    func signUp(email: String, password: String) -> Single<(uid: String, isAlreadySignUp: Bool)>
    /// sign in with kakao 시 이미 이전에 회원가입한 경우 사용
    func signIn(email: String, password: String) -> Single<String>
    func signOut() -> Single<Void>
    func withdrawal() -> Single<Void>
    func reauthenticateAuth(with credential: AuthCredential) -> Single<Void>
}

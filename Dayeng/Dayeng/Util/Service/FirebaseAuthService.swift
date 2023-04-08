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
    func signUp(with credential: OAuthCredential) -> Single<String>
    func signOut() -> Single<Void>
    func withdrawal() -> Single<Void>
    func reauthenticateAuth(with credential: AuthCredential) -> Single<Void>
}

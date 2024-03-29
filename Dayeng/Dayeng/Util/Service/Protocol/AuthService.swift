//
//  AuthService.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/04/06.
//

import Foundation
import RxSwift

protocol AuthService {
    func appleSignUp() -> Single<User>
    func appleSignIn() -> Single<String>
    func kakaoSignIn() -> Single<(user: User, isAlreadySignUp: Bool)>
    func signOut() -> Single<Void>
    func withdrawal() -> Single<Void>
}

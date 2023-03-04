//
//  AppleLoginService.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/25.
//

import Foundation
import RxSwift
import FirebaseAuth

protocol AppleLoginService {
    func signIn() -> Observable<(credential: OAuthCredential, name: String)>
    func autoSignIn() -> Observable<Bool>
}

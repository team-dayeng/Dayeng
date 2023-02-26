//
//  LoginUseCase.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/21.
//

import FirebaseAuth
import RxSwift

protocol LoginUseCase {
    func appleSignIn() -> Observable<Void>
    func signOut()
}

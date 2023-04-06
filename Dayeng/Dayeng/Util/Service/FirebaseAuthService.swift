//
//  FirebaseAuthService.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/04/02.
//

import Foundation
import RxSwift

protocol FirebaseAuthService {
    func signOut() -> Single<Void>
}

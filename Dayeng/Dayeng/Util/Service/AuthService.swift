//
//  AuthService.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/04/06.
//

import Foundation
import RxSwift

protocol AuthService {
    func signOut() -> Single<Void>
    func withdrawal() -> Single<Void>
}

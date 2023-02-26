//
//  SplashUseCase.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/11.
//

import Foundation
import RxSwift

protocol SplashUseCase {
    func isAvailableAppleLogin() -> Observable<Bool>
    func fetchQuestions() -> Observable<Void>
    func fetchUser(userID: String) -> Observable<Void>
}

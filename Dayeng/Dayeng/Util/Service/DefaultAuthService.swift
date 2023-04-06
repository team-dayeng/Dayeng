//
//  DefaultAuthService.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/04/06.
//

import Foundation
import RxSwift

final class DefaultAuthService: AuthService {
    enum AuthError: Error {
        case notExistSelf
    }
    
    private let firebaseAuthService: FirebaseAuthService
    private let appleLoginService: AppleLoginService
    private let kakaoLoginService: KakaoLoginService
    
    init(
        firebaseAuthService: FirebaseAuthService,
        appleLoginService: AppleLoginService,
        kakaoLoginService: KakaoLoginService
    ) {
        self.firebaseAuthService = firebaseAuthService
        self.appleLoginService = appleLoginService
        self.kakaoLoginService = kakaoLoginService
    }
    
    func signOut() -> Single<Void> {
        if UserDefaults.appleID == nil {
            return Single.zip(kakaoLoginService.signOut(), firebaseAuthService.signOut())
                .map { _ in }
                .do(onSuccess: {
                    UserDefaults.userID = nil
                })
        } else {
            appleLoginService.signOut()
            return firebaseAuthService.signOut()
                .do(onSuccess: {
                    UserDefaults.userID = nil
                })
        }
    }
}



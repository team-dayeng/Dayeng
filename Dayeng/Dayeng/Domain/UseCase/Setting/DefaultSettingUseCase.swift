//
//  DefaultSettingUseCase.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/03/04.
//

import Foundation
import RxSwift
import FirebaseAuth

final class DefaultSettingUseCase: SettingUseCase {
    
    enum SettingError: Error {
        case notExistSelf
        case notSocialLogined
        case authCredentialError
    }
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - Dependencies
    private let appleLoginService: AppleLoginService
    private let kakaoLoginService: KakaoLoginService
    private let authService: AuthService
    private let userRepository: UserRepository
    
    // MARK: - LifeCycles
    init(
        appleLoginService: AppleLoginService,
        kakaoLoginService: KakaoLoginService,
        authService: AuthService,
        userRepository: UserRepository
    ) {
        self.appleLoginService = appleLoginService
        self.kakaoLoginService = kakaoLoginService
        self.authService = authService
        self.userRepository = userRepository
    }
    
    func signOut() -> Single<Void> {
        authService.signOut()
            .do {
                UserDefaults.userID = nil
            }
    }
    
    func withdrawal() -> Single<Void> {
        Single.zip(authService.withdrawal(), deleteUser())
            .map { _ in }
            .do(onSuccess: {
                UserDefaults.userID = nil
            }, onError: { _ in
                UserDefaults.userID = nil
            })
    }
    
    /// DB에서 user 삭제
    private func deleteUser() -> Single<Void> {
        guard let userID = UserDefaults.userID else {
            return Single.error(UserError.cannotFetchUserID)
        }
        return userRepository.deleteUser(userID: userID)
    }
}

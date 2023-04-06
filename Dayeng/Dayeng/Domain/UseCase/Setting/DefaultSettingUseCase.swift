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
    }
    
    func withdrawal() -> Observable<Void> {
        Observable.create { [weak self] observer in
            guard let self else {
                observer.onError(SettingError.notExistSelf)
                return Disposables.create()
            }
            
            guard let user = Auth.auth().currentUser else {
                observer.onError(UserError.notExistCurrentUser)
                return Disposables.create()
            }
            
            user.delete { [weak self] error in
                guard let self else { return }
                
                if let error {
                    observer.onError(error)
                } else {
                    Observable.zip(self.socialWithDrawal(), self.deleteUser())
                        .map { _ in }
                        .do(onNext: {
                            UserDefaults.userID = nil
                        })
                        .bind(to: observer)
                        .disposed(by: self.disposeBag)
                }
            }
        
            return Disposables.create()
        }
    }
    
    private func socialWithDrawal() -> Observable<Void> {
        Observable.create { [weak self] observer in
            guard let self else {
                observer.onError(SettingError.notExistSelf)
                return Disposables.create()
            }
            
            if UserDefaults.appleID == nil {
                self.kakaoLoginService.withdrawal()
                    .subscribe(onCompleted: {
                        observer.onNext(())
                    }, onError: {
                        observer.onError($0)
                    })
                    .disposed(by: self.disposeBag)
            } else {
                self.appleLoginService.isLoggedIn()
                    .subscribe(onNext: { result in
                        if result {
//                            appleLoginService.withdrawal()
                        } else {
                            observer.onError(SettingError.notSocialLogined)
                        }
                    })
                    .disposed(by: self.disposeBag)
            }
            
            return Disposables.create()
        }
    }
    
    /// DB에서 user 삭제
    private func deleteUser() -> Observable<Void> {
        Observable.create { [weak self] observer in
            guard let self else {
                observer.onError(SettingError.notExistSelf)
                return Disposables.create()
            }
            guard let userID = UserDefaults.userID else {
                observer.onError(UserError.cannotFetchUserID)
                return Disposables.create()
            }
            
            self.userRepository.deleteUser(userID: userID)
                .bind(to: observer)
                .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }
}

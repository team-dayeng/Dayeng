//
//  DefaultLoginUseCase.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/21.
//

import Foundation
import FirebaseAuth
import RxSwift

final class DefaultLoginUseCase: LoginUseCase {
    
    enum LoginError: Error {
        case notExistSelf
    }
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let authService: AuthService
    
    // MARK: - Dependencies
    private let userRepository: UserRepository
    
    // MARK: - LifeCycles
    init(
        userRepository: UserRepository,
        authService: AuthService
    ) {
        self.userRepository = userRepository
        self.authService = authService
    }
    
    // MARK: - Helpers
    func appleSignIn() -> Observable<Void> {
        Observable.create { [weak self] observer in
            guard let self else {
                observer.onError(LoginError.notExistSelf)
                return Disposables.create()
            }
            if UserDefaults.isAppleSignedUp {   // 회원가입 O
                self.authService.appleSignIn()
                    .subscribe(onSuccess: { [weak self] uid in
                        guard let self else {
                            observer.onError(LoginError.notExistSelf)
                            return
                        }
                        self.fetchUser(uid)
                            .bind(to: observer)
                            .disposed(by: self.disposeBag)
                    }, onFailure: {
                        observer.onError($0)
                    })
                    .disposed(by: self.disposeBag)
            } else {    // 회원가입 X 또는 탈퇴
                self.authService.appleSignUp()
                    .subscribe(onSuccess: { [weak self] newUser in
                        guard let self else {
                            observer.onError(LoginError.notExistSelf)
                            return
                        }
                        self.uploadUser(newUser)
                            .do(onNext: {
                                UserDefaults.isAppleSignedUp = true
                            })
                            .bind(to: observer)
                            .disposed(by: self.disposeBag)
                    }, onFailure: {
                        observer.onError($0)
                    })
                    .disposed(by: self.disposeBag)
            }
            return Disposables.create()
        }
        .do(onError: { _ in
            UserDefaults.appleID = nil
        })
    }
    
    func kakaoSignIn() -> Observable<Void> {
        Observable.create { [weak self] observer in
            guard let self else {
                observer.onError(LoginError.notExistSelf)
                return Disposables.create()
            }
            
            self.authService.kakaoSignIn()
                .subscribe(onSuccess: { [weak self] (user, isAlreadySignUp) in
                    guard let self else {
                        observer.onError(LoginError.notExistSelf)
                        return
                    }
                    
                    if isAlreadySignUp {
                        self.fetchUser(user.uid)
                            .bind(to: observer)
                            .disposed(by: self.disposeBag)
                    } else {
                        self.uploadUser(user)
                            .bind(to: observer)
                            .disposed(by: self.disposeBag)
                    }
                }, onFailure: {
                    observer.onError($0)
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    private func uploadUser(_ user: User) -> Observable<Void> {
        userRepository.uploadUser(user: user)
            .do(onNext: {
                UserDefaults.userID = user.uid
                UserDefaults.userName = user.name
                DayengDefaults.shared.user = user
            })
    }
    
    private func fetchUser(_ uid: String) -> Observable<Void> {
        userRepository.fetchUser(userID: uid)
            .map { user in
                UserDefaults.userID = user.uid
                UserDefaults.userName = user.name
                DayengDefaults.shared.user = user
                return
            }
    }
}

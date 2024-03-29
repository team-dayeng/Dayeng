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
        case getCredentialError
        case notSocialLogined
    }
    
    private let firebaseAuthService: FirebaseAuthService
    private let appleLoginService: AppleLoginService
    private let kakaoLoginService: KakaoLoginService
    private let disposeBag = DisposeBag()
    
    init(
        firebaseAuthService: FirebaseAuthService,
        appleLoginService: AppleLoginService,
        kakaoLoginService: KakaoLoginService
    ) {
        self.firebaseAuthService = firebaseAuthService
        self.appleLoginService = appleLoginService
        self.kakaoLoginService = kakaoLoginService
    }
    
    func appleSignUp() -> Single<User> {
        Single.create { [weak self] single in
            guard let self else {
                single(.failure(AuthError.notExistSelf))
                return Disposables.create()
            }
            self.appleLoginService.signIn()
                .subscribe(onNext: { [weak self] (credential, userName) in
                    guard let self else {
                        single(.failure(AuthError.notExistSelf))
                        return
                    }
                    self.firebaseAuthService.signUp(with: credential)
                        .subscribe(onSuccess: { uid in
                            let newUser = User(uid: uid, name: userName)
                            single(.success(newUser))
                        }, onFailure: {
                            single(.failure($0))
                        })
                        .disposed(by: self.disposeBag)
                }, onError: {
                    single(.failure($0))
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func appleSignIn() -> Single<String> {
        Single.create { [weak self] single in
            guard let self else {
                single(.failure(AuthError.notExistSelf))
                return Disposables.create()
            }
            self.appleLoginService.signIn()
                .subscribe(onNext: { [weak self] (credential, _) in
                    guard let self else {
                        single(.failure(AuthError.notExistSelf))
                        return
                    }
                    self.firebaseAuthService.signUp(with: credential)
                        .subscribe(onSuccess: { uid in
                            single(.success(uid))
                        }, onFailure: {
                            single(.failure($0))
                        })
                        .disposed(by: self.disposeBag)
                }, onError: {
                    single(.failure($0))
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func kakaoSignIn() -> Single<(user: User, isAlreadySignUp: Bool)> {
        Single.create { [weak self] single in
            guard let self else {
                single(.failure(AuthError.notExistSelf))
                return Disposables.create()
            }
            
            self.kakaoLoginService.signIn()
                .subscribe(onNext: { [weak self] (email, password, userName) in
                    guard let self else {
                        single(.failure(AuthError.notExistSelf))
                        return
                    }
                    self.firebaseAuthService.signUp(email: email, password: password)
                        .subscribe(onSuccess: { (uid, isAlreadySignUp) in
                            let user = User(uid: uid, name: userName)
                            single(.success((user, isAlreadySignUp)))
                        }, onFailure: {
                            single(.failure($0))
                        })
                        .disposed(by: self.disposeBag)
                }, onError: {
                    single(.failure($0))
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    func signOut() -> Single<Void> {
        if UserDefaults.appleID == nil {
            return Single.zip(kakaoLoginService.signOut(), firebaseAuthService.signOut())
                .map { _ in }
        } else {
            appleLoginService.signOut()
            return firebaseAuthService.signOut()
        }
    }
    
    func withdrawal() -> Single<Void> {
        Observable<Void>.create { [weak self] observer in
            guard let self else {
                observer.onError(AuthError.notExistSelf)
                return Disposables.create()
            }
            if UserDefaults.appleID == nil {
                Single.zip(self.kakaoLoginService.withdrawal(), self.firebaseAuthService.withdrawal())
                    .map { _ in }
                    .asObservable()
                    .bind(to: observer)
                    .disposed(by: self.disposeBag)
                    
            } else {
                self.appleLoginService.reauthenticate()
                    .subscribe(onNext: { credential in
                        self.firebaseAuthService.reauthenticateAuth(with: credential)
                            .subscribe(onSuccess: { [weak self] _ in
                                guard let self else {
                                    observer.onError(AuthError.notExistSelf)
                                    return
                                }
                                self.appleLoginService.withdrawal()
                                self.firebaseAuthService.withdrawal()
                                    .asObservable()
                                    .bind(to: observer)
                                    .disposed(by: self.disposeBag)
                            }, onFailure: { error in
                                observer.onError(error)
                            })
                            .disposed(by: self.disposeBag)
                    }, onError: {
                        observer.onError($0)
                    })
                    .disposed(by: self.disposeBag)
            }
            return Disposables.create()
        }.asSingle()
    }
}

//
//  DefaultKakaoLoginService.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/26.
//

import Foundation
import KakaoSDKAuth
import KakaoSDKUser
import KakaoSDKCommon
import RxKakaoSDKAuth
import RxKakaoSDKUser
import RxSwift

final class DefaultKakaoLoginService: KakaoLoginService {
    
    enum KakaoLoginServiceError: Error {
        case notExistSelf
        case notFetchUser
        case signOutError
        case withdrawalError
    }
    
    private let disposeBag = DisposeBag()

    func isLoggedIn() -> Observable<Bool> {
        Observable.create { [weak self] observer in
            guard let self else {
                observer.onNext(false)
                return Disposables.create()
            }
            if AuthApi.hasToken() {
                UserApi.shared.rx.accessTokenInfo()
                    .subscribe(onSuccess: { _ in
                        observer.onNext(true)
                    }, onFailure: { error in
                        if let sdkError = error as? SdkError,
                           sdkError.isInvalidTokenError() == true {
                            observer.onNext(false)
                        } else {
                            observer.onError(error)
                        }
                    })
                    .disposed(by: self.disposeBag)
            } else {
                observer.onNext(false)
            }
            
            return Disposables.create()
        }
    }
    
    func signIn() -> Observable<(email: String, password: String, userName: String)> {
        Observable.create { [weak self] observer in
            guard let self else {
                observer.onError(KakaoLoginServiceError.notExistSelf)
                return Disposables.create()
            }
            self.loginWithKakaoTalk()
                .withUnretained(self)
                .subscribe(onNext: { (owner, _) in
                    owner.getUserInfo()
                        .bind(to: observer)
                        .disposed(by: owner.disposeBag)
                }, onError: {
                    observer.onError($0)
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func signOut() -> Single<Void> {
        Single.create { [weak self] single in
            guard let self else {
                single(.failure(KakaoLoginServiceError.notExistSelf))
                return Disposables.create()
            }
            UserApi.shared.rx.logout()
                .subscribe(onCompleted: {
                    single(.success(()))
                }, onError: { _ in
                    single(.failure(KakaoLoginServiceError.signOutError))
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func withdrawal() -> Single<Void> {
        Single.create { [weak self] single in
            guard let self else {
                single(.failure(KakaoLoginServiceError.notExistSelf))
                return Disposables.create()
            }
            UserApi.shared.rx.unlink()
                .subscribe(onCompleted: {
                    single(.success(()))
                }, onError: { _ in
                    single(.failure(KakaoLoginServiceError.withdrawalError))
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    private func loginWithKakaoTalk() -> Observable<OAuthToken> {
        if UserApi.isKakaoTalkLoginAvailable() {
            return UserApi.shared.rx.loginWithKakaoTalk()
        }
        return UserApi.shared.rx.loginWithKakaoAccount()
    }
    
    private func getUserInfo() -> Observable<(email: String, password: String, userName: String)> {
        UserApi.shared.rx.me()
            .asObservable()
            .map { user -> (email: String, password: String, userName: String) in
                guard let email = user.kakaoAccount?.email,
                      let userID = user.id,
                      let userName = user.kakaoAccount?.profile?.nickname else {
                    throw KakaoLoginServiceError.notFetchUser
                }
                return (email, String(userID), userName)
            }
    }
}

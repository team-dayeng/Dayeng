//
//  DefaultKakaoLoginService.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/26.
//

import Foundation
import KakaoSDKAuth
import KakaoSDKUser
import RxKakaoSDKAuth
import RxKakaoSDKUser
import RxSwift
import FirebaseAuth

final class DefaultKakaoLoginService: KakaoLoginService {
    
    enum KakaoLoginError: Error {
        case notFetchUser
    }
    
    private let disposeBag = DisposeBag()
    
    func isAvailable() -> Bool {
        AuthApi.hasToken()
    }
    
    func autoSignIn() -> Observable<Void> {
        UserApi.shared.rx.accessTokenInfo()
            .map { _ in }
            .asObservable()
    }
    
    func signIn() -> Observable<(email: String, password: String, userName: String)> {
        Observable.create { [weak self] observer in
            guard let self else { return Disposables.create() }
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
    
    func signOut() -> Completable {
        UserApi.shared.rx.logout()
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
                    throw KakaoLoginError.notFetchUser
                }
                return (email, String(userID), userName)
            }
    }
}

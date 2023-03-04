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
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - Dependencies
    private let appleLoginService: AppleLoginService
    private let kakaoLoginService: KakaoLoginService
    
    // MARK: - LifeCycles
    init(
        appleLoginService: AppleLoginService,
        kakaoLoginService: KakaoLoginService
    ) {
        self.appleLoginService = appleLoginService
        self.kakaoLoginService = kakaoLoginService
    }
    
    func logout() -> Observable<Bool> {
        Observable.create { [weak self] observer in
            guard let self else { return Disposables.create() }
            if Auth.auth().currentUser != nil {
                do {
                    try Auth.auth().signOut()
                } catch {
                    observer.onNext(false)
                    observer.onCompleted()
                }
            }
            
            if self.kakaoLoginService.isAvailableAutoSignIn() {
                self.kakaoLoginService.signOut()
                    .subscribe(onCompleted: {
                        observer.onNext(true)
                    }, onError: { _ in
                        observer.onNext(false)
                    })
                    .disposed(by: self.disposeBag)
            } else {    // case: apple login
//                appleLoginService.signOut()
            }
            return Disposables.create()
        }
    }
    
    func withdrawal() -> Observable<Bool> {
        Observable.create { [weak self] observer in
            guard let self else { return Disposables.create() }
            if let user = Auth.auth().currentUser {
                user.delete { error in
                    if error != nil {
                        observer.onNext(false)
                        observer.onCompleted()
                    }
                }
            }
            
            if self.kakaoLoginService.isAvailableAutoSignIn() {
                self.kakaoLoginService.unlink()
                    .subscribe(onCompleted: {
                        observer.onNext(true)
                    }, onError: { _ in
                        observer.onNext(false)
                    })
                    .disposed(by: self.disposeBag)
            } else {    // case: apple login
//                appleLoginService.withdrawal()
            }
            return Disposables.create()
        }
    }
    
}

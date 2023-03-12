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
        case firebaseAuthSignOutError
        case notSocialLogined
    }
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - Dependencies
    private let appleLoginService: AppleLoginService
    private let kakaoLoginService: KakaoLoginService
    private let userRepository: UserRepository
    
    // MARK: - LifeCycles
    init(
        appleLoginService: AppleLoginService,
        kakaoLoginService: KakaoLoginService,
        userRepository: UserRepository
    ) {
        self.appleLoginService = appleLoginService
        self.kakaoLoginService = kakaoLoginService
        self.userRepository = userRepository
    }
    
    func logout() -> Observable<Void> {
        Observable.create { [weak self] observer in
            guard let self else {
                observer.onError(SettingError.notExistSelf)
                return Disposables.create()
            }
            
            guard Auth.auth().currentUser != nil else {
                observer.onError(UserError.notExistCurrentUser)
                return Disposables.create()
            }
            
            do {
                try Auth.auth().signOut()
                self.socialLogout()
                    .do(onNext: {
                        UserDefaults.userID = nil
                    })
                    .bind(to: observer)
                    .disposed(by: self.disposeBag)
            } catch {
                observer.onError(SettingError.firebaseAuthSignOutError)
            }
            
            return Disposables.create()
        }
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
                    // 에러나면 로그인 후 다시 시도
                    Observable.zip(self.socialWithDrawal(), self.deleteUser())
                        .map{ (_, _) in }
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
    
    private func socialLogout() -> Observable<Void> {
        Observable.create { [weak self] observer in
            guard let self else {
                observer.onError(SettingError.notExistSelf)
                return Disposables.create()
            }
            
            if self.kakaoLoginService.isLoggedIn() {
                self.kakaoLoginService.signOut()
                    .subscribe(onCompleted: {
                        observer.onNext(())
                    }, onError: { error in
                        observer.onError(error)
                    })
                    .disposed(by: self.disposeBag)
            } else {
                self.appleLoginService.isLoggedIn()
                    .subscribe(onNext: { result in
                        if result {
//                            appleLoginService.signOut()
                        } else {
                            observer.onError(SettingError.notSocialLogined)
                        }
                    })
                    .disposed(by: self.disposeBag)
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
            
            if self.kakaoLoginService.isLoggedIn() {
                self.kakaoLoginService.unlink()
                    .subscribe(onCompleted: {
                        observer.onNext(())
                    }, onError: { error in
                        observer.onError(error)
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

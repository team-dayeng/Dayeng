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
        case cannotFetchUserUid
    }
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let authService: AuthService
    private let kakaoLoginService: KakaoLoginService
    
    // MARK: - Dependencies
    private let userRepository: UserRepository
    
    // MARK: - LifeCycles
    init(
        userRepository: UserRepository,
        authService: AuthService,
        kakaoLoginService: KakaoLoginService
    ) {
        self.userRepository = userRepository
        self.authService = authService
        self.kakaoLoginService = kakaoLoginService
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
                        self.userRepository.fetchUser(userID: uid)
                            .map { user in
                                UserDefaults.userID = user.uid
                                UserDefaults.userName = user.name
                                DayengDefaults.shared.user = user
                                return
                            }
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
            
            self.kakaoLoginService.signIn()
                .subscribe(onNext: { [weak self] (email, password, userName) -> Void in
                    guard let self else { return }
                    
                    self.firebaseSignUp(email: email, password: password, userName: userName)
                        .do(onError: { [weak self] _ in
                            guard let self else { return }
                            self.kakaoLoginService.signOut()
                                .asObservable()
                                .map { _ in }
                                .bind(to: observer)
                                .disposed(by: self.disposeBag)
                        })
                        .bind(to: observer)
                        .disposed(by: self.disposeBag)
                            
                }, onError: {
                    observer.onError($0)
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    private func firebaseSignOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("sign out error: \(error)")
        }
    }
    
    /// 카카오 로그인시 사용 (이전 가입 기록 X)
    private func firebaseSignUp(email: String, password: String, userName: String) -> Observable<Void> {
        Observable.create { observer in
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] (_, error) in
                guard let self else { return }
                
                if let error = error as? AuthErrorCode {
                    if error.code == .emailAlreadyInUse {
                        self.firebaseSignIn(email: email, password: password, userName: userName)
                            .bind(to: observer)
                            .disposed(by: self.disposeBag)

                    } else {
                        observer.onError(error)
                    }
                    return
                }
                
                guard let uid = Auth.auth().currentUser?.uid else {
                    observer.onError(LoginError.cannotFetchUserUid)
                    return
                }
                
                let newUser = User(uid: uid, name: userName)
                self.uploadUser(newUser)
                    .bind(to: observer)
                    .disposed(by: self.disposeBag)
            }
            return Disposables.create()
        }
    }
    
    /// 카카오 로그인시 사용 (이전 가입 기록 O)
    private func firebaseSignIn(email: String, password: String, userName: String) -> Observable<Void> {
        Observable.create { observer in
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] (_, error) in
                guard let self else { return }
                
                if let error {
                    observer.onError(error)
                    return
                }
                
                guard let uid = Auth.auth().currentUser?.uid else {
                    observer.onError(LoginError.cannotFetchUserUid)
                    return
                }
                
                self.userRepository.fetchUser(userID: uid)
                    .map { user in
                        UserDefaults.userID = user.uid
                        DayengDefaults.shared.user = user
                        return
                    }
                    .bind(to: observer)
                    .disposed(by: self.disposeBag)
            }
            return Disposables.create()
        }
    }
    
    private func uploadUser(_ user: User) -> Observable<Void> {
        userRepository.uploadUser(user: user)
            .do(onNext: {
                UserDefaults.userID = user.uid
                UserDefaults.userName = user.name
                DayengDefaults.shared.user = user
            }, onError: { [weak self] _ in
                guard let self else { return }
                self.firebaseSignOut()
            })
    }
}

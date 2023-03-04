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
        case cannotFetchUserUid
    }
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let appleLoginService: AppleLoginService
    private let kakaoLoginService: KakaoLoginService
    
    // MARK: - Dependencies
    private let userRepository: UserRepository
    
    // MARK: - LifeCycles
    init(
        userRepository: UserRepository,
        appleLoginService: AppleLoginService,
        kakaoLoginService: KakaoLoginService
    ) {
        self.userRepository = userRepository
        self.appleLoginService = appleLoginService
        self.kakaoLoginService = kakaoLoginService
    }
    
    // MARK: - Helpers
    
    func appleSignIn() -> Observable<Void> {
        Observable.create { [weak self] observer in
            guard let self else { return Disposables.create() }
            self.appleLoginService.signIn()
                .subscribe(onNext: { [weak self] (credential, userName) in
                    guard let self else { return }
                    self.firebaseSignIn(credential: credential, userName: userName)
//                        .do(onError: {
//                            // 애플 로그아웃
//                        })
                        .bind(to: observer)
                        .disposed(by: self.disposeBag)
                }, onError: { error in
                    print(error.localizedDescription)
                    UserDefaults.appleID = nil
                    
                    observer.onError(error)
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func kakaoSignIn() -> Observable<Void> {
        Observable.create { [weak self] observer in
            guard let self else { return Disposables.create() }
            self.kakaoLoginService.signIn()
                .subscribe(onNext: { [weak self] (email, password, userName) -> Void in
                    guard let self else { return }
                    self.firebaseSignUp(email: email, password: password, userName: userName)
                        .do(onError: { [weak self] _ in
                            // kakao 로그아웃
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
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("sign out error: \(error)")
        }
    }
    
    private func firebaseSignIn(credential: OAuthCredential, userName: String) -> Observable<Void> {
        Observable.create { observer in
            Auth.auth().signIn(with: credential) { [weak self] (_, error) in
                guard let self else { return }
                
                if let error {
                    observer.onError(error)
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
    
    private func firebaseSignUp(email: String, password: String, userName: String) -> Observable<Void> {
        Observable.create { observer in
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] (_, error) in
                guard let self else { return }
                
                if error != nil {
                    self.firebaseSignIn(email: email, password: password, userName: userName)
                        .bind(to: observer)
                        .disposed(by: self.disposeBag)
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
                
                let newUser = User(uid: uid, name: userName)
                self.uploadUser(newUser)
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
                DayengDefaults.shared.questions = []
                DayengDefaults.shared.user = user
            }, onError: { [weak self] _ in
                guard let self else { return }
                self.signOut()
            })
    }
}

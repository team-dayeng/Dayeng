//
//  DefaultFirebaseAuthService.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/04/02.
//

import Foundation
import RxSwift
import FirebaseAuth

final class DefaultFirebaseAuthService: FirebaseAuthService {
    
    enum FirebaseAuthError: Error {
        case notExistSelf
        case cannotFetchUid
        case signOutError
        case userDeleteError
        case reauthenticateError
    }
    
    private let disposeBag = DisposeBag()
    
    func signUp(with credential: OAuthCredential) -> Single<String> {
        Single.create { single in
            Auth.auth().signIn(with: credential) { (_, error) in
                if let error {
                    single(.failure(error))
                    return
                }
                guard let uid = Auth.auth().currentUser?.uid else {
                    single(.failure(FirebaseAuthError.cannotFetchUid))
                    return
                }
                single(.success(uid))
            }
            return Disposables.create()
        }
    }
    
    func signUp(email: String, password: String) -> Single<(uid: String, isAlreadySignUp: Bool)> {
        Single.create { single in
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] (_, error) in
                guard let self else {
                    single(.failure(FirebaseAuthError.notExistSelf))
                    return
                }
                
                if let error = error as? AuthErrorCode {
                    if error.code == .emailAlreadyInUse {
                        self.signIn(email: email, password: password)
                            .subscribe(onSuccess: { uid in
                                single(.success((uid, true)))
                            }, onFailure: {
                                single(.failure($0))
                            })
                            .disposed(by: self.disposeBag)
                    } else {
                        single(.failure(error))
                    }
                    return
                }
                
                guard let uid = Auth.auth().currentUser?.uid else {
                    single(.failure(FirebaseAuthError.cannotFetchUid))
                    return
                }
                single(.success((uid, false)))
            }
            return Disposables.create()
        }
    }
    
    /// 이미 카카오 회원가입이 된 경우
    func signIn(email: String, password: String) -> Single<String> {
        Single.create { single in
            Auth.auth().signIn(withEmail: email, password: password) { (_, error) in
                
                if let error {
                    single(.failure(error))
                    return
                }
                
                guard let uid = Auth.auth().currentUser?.uid else {
                    single(.failure(FirebaseAuthError.cannotFetchUid))
                    return
                }
                
                single(.success(uid))
            }
            return Disposables.create()
        }
    }
    
    func signOut() -> Single<Void> {
        Single.create { single in
            guard Auth.auth().currentUser != nil else {
                single(.failure(UserError.notExistCurrentUser))
                return Disposables.create()
            }
            
            do {
                try Auth.auth().signOut()
                single(.success(()))
            } catch {
                single(.failure(FirebaseAuthError.signOutError))
            }
            
            return Disposables.create()
        }
    }
    
    func withdrawal() -> Single<Void> {
        Single.create { single in
            guard let user = Auth.auth().currentUser else {
                single(.failure(UserError.notExistCurrentUser))
                return Disposables.create()
            }
            
            user.delete { error in
                if error != nil {
                    single(.failure(FirebaseAuthError.userDeleteError))
                } else {
                    single(.success(()))
                }
            }
            return Disposables.create()
        }
    }
    
    func reauthenticateAuth(with credential: AuthCredential) -> Single<Void> {
        Single.create { single in
            guard let user = Auth.auth().currentUser else {
                single(.failure(UserError.notExistCurrentUser))
                return Disposables.create()
            }
            
            user.reauthenticate(with: credential) { (_, error) in
                if let error {
                    print(error.localizedDescription)
                    single(.failure(FirebaseAuthError.reauthenticateError))
                } else {
                    single(.success(()))
                }
            }
            return Disposables.create()
        }
    }
    
}

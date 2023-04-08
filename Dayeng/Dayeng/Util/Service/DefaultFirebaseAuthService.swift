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

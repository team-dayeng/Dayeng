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
        case signOutError
        case userDeleteError
        case reauthenticateError
    }
    
    private let auth = Auth.auth()
    
    func signOut() -> Single<Void> {
        Single.create { [weak self] single in
            guard let self else {
                single(.failure(FirebaseAuthError.notExistSelf))
                return Disposables.create()
            }
            
            guard self.auth.currentUser != nil else {
                single(.failure(UserError.notExistCurrentUser))
                return Disposables.create()
            }
            
            do {
                try self.auth.signOut()
                single(.success(()))
            } catch {
                single(.failure(FirebaseAuthError.signOutError))
            }
            
            return Disposables.create()
        }
    }
    
    func withdrawal() -> Single<Void> {
        Single.create { [weak self] single in
            guard let self else {
                single(.failure(FirebaseAuthError.notExistSelf))
                return Disposables.create()
            }
            guard let user = self.auth.currentUser else {
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
        Single.create { [weak self] single in
            guard let self else {
                single(.failure(FirebaseAuthError.notExistSelf))
                return Disposables.create()
            }
            guard let user = self.auth.currentUser else {
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

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
    
}

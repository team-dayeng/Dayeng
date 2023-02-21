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
    
    // MARK: - Dependencies
    private let userRepository: UserRepository
    
    // MARK: - LifeCycles
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    // MARK: - Helpers
    
    func signIn(credential: OAuthCredential, userName: String) -> Observable<String> {
        Observable.create { observer in
            Auth.auth().signIn(with: credential) { [weak self] (_, error) in
                guard let self else { return }
                
                if let error {
                    observer.onError(error)
                    return
                }
                
                guard let uid = Auth.auth().currentUser?.uid else {
                    self.signOut()
                    observer.onError(LoginError.cannotFetchUserUid)
                    return
                }
                
                self.userRepository.uploadUser(user: User(uid: uid, name: userName))
                    .subscribe(onNext: {
                        observer.onNext(uid)
                    }, onError: {
                        self.signOut()
                        observer.onError($0)
                    })
                    .disposed(by: self.disposeBag)
            }
            return Disposables.create()
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("sign out error: \(error)")
        }
    }
}

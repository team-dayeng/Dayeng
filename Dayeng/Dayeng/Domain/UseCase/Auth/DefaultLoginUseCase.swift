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
    
    // MARK: - Dependencies
    private let userRepository: UserRepository
    
    // MARK: - LifeCycles
    init(userRepository: UserRepository, appleLoginService: AppleLoginService) {
        self.userRepository = userRepository
        self.appleLoginService = appleLoginService
    }
    
    // MARK: - Helpers
    
    func appleSignIn() -> Observable<Void> {
        Observable.create { [weak self] observer in
            guard let self else { return Disposables.create() }
            self.appleLoginService.signIn()
                .subscribe(onNext: { [weak self] (credential, userName) in
                    guard let self else { return }
                    self.firebaseAuthSignIn(credential: credential, userName: userName)
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
    
    private func firebaseAuthSignIn(credential: OAuthCredential, userName: String) -> Observable<Void> {
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
                
                let newUser = User(uid: uid, name: userName)
                self.userRepository.uploadUser(user: newUser)
                    .subscribe(onNext: {
                        UserDefaults.userID = uid
                        DayengDefaults.shared.questions = []
                        DayengDefaults.shared.user = newUser
                        
                        observer.onNext(())
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

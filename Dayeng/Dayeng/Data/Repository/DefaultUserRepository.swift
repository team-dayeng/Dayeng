//
//  DefaultUserRepository.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/03.
//

import Foundation
import RxSwift

final class DefaultUserRepository: UserRepository {
    
    enum UserRepositoryError: Error {
        case noUserError
        case notExistSelf
    }
    
    let firestoreService: FirestoreDatabaseService
    private let disposeBag = DisposeBag()
    
    init(firestoreService: FirestoreDatabaseService) {
        self.firestoreService = firestoreService
    }
    
    func fetchUser(userID: String) -> Observable<User> {
        Observable.zip(
            firestoreService.fetch(collection: "users", document: userID),
            firestoreService.fetch(api: .answer(userID: userID))
        ).map { (userDTO: UserDTO, answers: [AnswerDTO]) in
            var user = userDTO.toDomain(uid: userID)
            user.answers = answers.map { $0.toDomain() }
            return user
        }
    }
    
    func uploadUser(user: User) -> Observable<Void> {
        return firestoreService.upload(
            collection: "users",
            document: user.uid,
            dto: UserDTO(name: user.name,
                         answers: nil,
                         currentIndex: user.currentIndex,
                         friends: user.friends)
        )
    }
    
    func uploadAnswer(answer: String) -> Observable<Void> {
        guard let user = DayengDefaults.shared.user else {
            return Observable.error(UserRepositoryError.noUserError)
        }
        
        let answerDate = Date().convertToString(format: "yyyy.MM.dd.E")
        DayengDefaults.shared.addAnswer(Answer(
            date: answerDate,
            answer: answer)
        )
        
        if user.answers.count < user.currentIndex {
            return Observable.merge(
                firestoreService.upload(
                    api: .answer(userID: user.uid, index: user.answers.count),
                    dto: AnswerDTO(
                        date: answerDate,
                        answer: answer
                    )
                ),
                firestoreService.upload(
                    api: .currentIndex(userID: user.uid),
                    dto: ["currentIndex": user.currentIndex]
                )
            )
        }
        
        return Observable.merge(
            firestoreService.upload(
                api: .answer(userID: user.uid, index: user.currentIndex),
                dto: AnswerDTO(
                    date: answerDate,
                    answer: answer
                )
            ),
            firestoreService.upload(
                api: .currentIndex(userID: user.uid),
                dto: ["currentIndex": user.currentIndex + 1]
            )
        )
    }
    
    func editAnswer(answer: String, index: Int) -> Observable<Void> {
        guard let user = DayengDefaults.shared.user else {
            return Observable.error(UserRepositoryError.noUserError)
        }
        
        DayengDefaults.shared.editAnswer(
            Answer(date: user.answers[index].date, answer: answer), index
        )
        
        return firestoreService.upload(
            api: .answer(userID: user.uid, index: index),
            dto: AnswerDTO(date: user.answers[index].date,
                           answer: answer)
        )
    }
    
    func existUser(userID: String) -> Observable<String> {
        return firestoreService.fetchPath(collection: "users",
                                      document: userID)
    }
    
    func fetchFriends(paths: [String]) -> Observable<[User]> {
        Observable.create { observer in
            
            if paths.isEmpty {
                observer.onNext([])
            } else {
                Observable.zip(
                    paths.map { path in
                        let uid = path.split(separator: "/").map { String($0) }[1]
                        return self.fetchUser(userID: uid)
                    }
                )
                .bind(to: observer)
                .disposed(by: self.disposeBag)
            }
            
            return Disposables.create()
        }
    }
    
    func addFriend(user: User) -> Observable<Void> {
        return firestoreService.upload(collection: "users",
                                       document: user.uid,
                                       dto: UserDTO(name: user.name,
                                                    currentIndex: user.currentIndex,
                                                    friends: user.friends))
	}

    func deleteUser(userID: String) -> Single<Void> {
        Single.create { [weak self] single in
            guard let self else {
                single(.failure(UserRepositoryError.notExistSelf))
                return Disposables.create()
            }
            self.firestoreService.deleteDocument(api: .user(userID: userID))
                .subscribe(onNext: {
                    single(.success(()))
                }, onError: {
                    single(.failure($0))
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
}

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
            return Observable<Void>.create { observer in
                observer.onError(UserRepositoryError.noUserError)
                return Disposables.create()
            }
        }
        
        let answerDate = Date().convertToString(format: "yyyy.MM.dd.E")
        DayengDefaults.shared.addAnswer(Answer(
            date: answerDate,
            answer: answer)
        )
        
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
    
    func existUser(userID: String) -> Observable<String> {
        return firestoreService.fetchPath(collection: "users",
                                      document: userID)
    }
    
    func fetchFriends(paths: [String]) -> Observable<[User]> {
        Observable.create { observer in
            
            if paths.isEmpty {
                observer.onNext([])
            } else {
                Observable.zip(paths.map { path in
                    self.firestoreService.fetch(path: path)
                        .map { (userDTO: UserDTO) in
                            let uid = path.split(separator: "/").map { String($0) }[1]
                            return userDTO.toDomain(uid: uid)
                        }
                })
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
}

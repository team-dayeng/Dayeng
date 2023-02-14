//
//  DefaultUserRepository.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/03.
//

import Foundation
import RxSwift

final class DefaultUserRepository: UserRepository {
    let firestoreService: FirestoreDatabaseService
    
    init(firestoreService: FirestoreDatabaseService) {
        self.firestoreService = firestoreService
    }
    
    func fetchUser(userID: String) -> Observable<User> {
        firestoreService
            .fetch(collection: "users", document: userID)
            .map { (userDTO: UserDTO) in
                return User(uid: "uid",
                            currentIndex: userDTO.currentIndex,
                            answers: userDTO.answers.map { $0.toDomain() },
                            friends: userDTO.friends)
            }
    }
    
    func uploadUser(userID: String, user: User) -> Observable<Void> {
        return firestoreService
            .upload(collection: "user",
                    document: userID,
                    dto: UserDTO(answers: [],
                                 currentIndex: user.currentIndex,
                                 friends: user.friends))
    }
    
    func uploadAnswer(userID: String, index: Int, answer: String) -> Observable<Void> {
        firestoreService.upload(api: .answer(userID: userID), dto: AnswerDTO(date: Date().convertToString(format: "YYYY-mm-dd"), answer: ""))
    }
}

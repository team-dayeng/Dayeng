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
                var answerDictonary = [Int: String]()
                userDTO.answers?.forEach {
                    if let key = Int($0.key) {
                        answerDictonary[key] = $0.value
                    }
                }
                
                return User(answers: answerDictonary,
                            currentIndex: userDTO.currentIndex,
                            friends: userDTO.friends)
            }
    }
    
    func uploadUser(userID: String, user: User) -> Observable<Void> {
        var answerDictionary = [String: String]()
        user.answers?.forEach { answerDictionary["\($0.key)"] = $0.value }
        
        return firestoreService
            .upload(collection: "user",
                    document: userID,
                    dto: UserDTO(answers: answerDictionary,
                                 currentIndex: user.currentIndex,
                                 friends: user.friends))
    }
    
    func uploadAnswer(userID: String, index: Int, answer: String) -> Observable<Void> {
        firestoreService.upload(api: .answer(userID: userID), dto: AnswerDTO(answer: [index: answer]))
    }
}

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
                         answers: user.answers.map { AnswerDTO(date: $0.date, answer: $0.answer)},
                         currentIndex: user.currentIndex,
                         friends: user.friends,
                         bonusQuestionDate: user.bonusQuestionDate)
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
}

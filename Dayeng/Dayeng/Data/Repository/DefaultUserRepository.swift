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
        case dataConvertError
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
            
            // cache
            DefaultDayengCacheService.shared.write("userID", data: userID)
            DefaultDayengCacheService.shared.write("userName", data: user.name)
            DefaultDayengCacheService.shared.write("currentIndex", data: user.currentIndex)
            DefaultDayengCacheService.shared.write("friends", data: user.friends)
            DefaultDayengCacheService.shared.write("answers", data: answers)
            
            return user
        }
    }
    
    func uploadUser(user: User) -> Observable<Void> {
        firestoreService.upload(
            collection: "users",
            document: user.name,
            dto: UserDTO(name: user.name,
                         answers: nil,
                         currentIndex: user.currentIndex,
                         friends: user.friends)
        )
    }
    
    func uploadAnswer(answer: String) -> Observable<Void> {
        
        guard let userIDData = DefaultDayengCacheService.shared.load("userID"),
              let indexData = DefaultDayengCacheService.shared.load("currentIndex"),
              let userID = userIDData.toString(),
              let index = indexData.toInt() else {
            return Observable<Void>.create { observer in
                observer.onError(UserRepositoryError.dataConvertError)
                return Disposables.create()
            }
        }
        
        DefaultDayengCacheService.shared.write("currentIndex", data: index + 1)
        return Observable.merge(
            firestoreService.upload(
                api: .answer(userID: userID, index: index),
                dto: AnswerDTO(
                    date: Date().convertToString(format: "yyyy.MM.dd.E"),
                    answer: answer
                )
            )
            ,
            firestoreService.upload(
                api: .currentIndex(userID: userID),
                dto: ["currentIndex": index + 1]
            )
        )
        
        // 캐시에 answers도 업데이트
    }
}

//
//  UserDTO.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/03.
//

import Foundation

struct UserDTO: Codable {
    var name: String
    var answers: [AnswerDTO]?
    var currentIndex: Int
    var friends: [String]
    var bonusQuestionDate: Date?
    
    func toDomain(uid: String) -> User {
        User(uid: uid,
             name: name,
             answers: answers != nil ? answers!.map { $0.toDomain() } : [],
             currentIndex: currentIndex,
             friends: friends,
             bonusQuestionDate: bonusQuestionDate
        )
    }
}

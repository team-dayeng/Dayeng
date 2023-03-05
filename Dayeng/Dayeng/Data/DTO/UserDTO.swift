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
    
    func toDomain(uid: String) -> User {
        User(uid: uid,
             name: name,
             answers: answers != nil ? answers!.map { $0.toDomain() } : [],
             currentIndex: currentIndex,
             friends: friends)
    }
    
    func toDomain() -> User {
        User(uid: UUID().uuidString,
             name: name,
             answers: answers != nil ? answers!.map { $0.toDomain() } : [],
             currentIndex: currentIndex,
             friends: friends)
    }
}

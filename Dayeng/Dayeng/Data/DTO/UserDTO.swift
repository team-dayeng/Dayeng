//
//  UserDTO.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/03.
//

import Foundation

struct UserDTO: Codable {
    var answers: [AnswerDTO]
    var currentIndex: Int
    var friends: [String]
    
    func toDomain() -> User {
        User(currentIndex: currentIndex,
             answers: answers.map { $0.toDomain() },
             friends: friends)
    }
}

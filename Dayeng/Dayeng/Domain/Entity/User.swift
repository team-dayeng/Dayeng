//
//  User.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/03.
//

import Foundation

struct User: Hashable {
    let uid: String
    var currentIndex: Int
    var answers: [String?]
    var friends: [String]
    
    init(uid: String = UUID().uuidString,
         currentIndex: Int = 0,
         answers: [String?] = [],
         friends: [String] = []) {
        self.uid = uid
        self.currentIndex = currentIndex
        self.answers = answers
        self.friends = friends
    }
}

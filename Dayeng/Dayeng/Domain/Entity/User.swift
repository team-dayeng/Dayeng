//
//  User.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/03.
//

import Foundation

// CollectionView Diffable Datasource의 Item에 사용하기 위해 Hashable
struct User: Hashable {
    let uid: String
    var name: String
    var answers: [Answer]
    var currentIndex: Int
    var friends: [String]
    
    init(uid: String = UUID().uuidString,
         name: String,
         answers: [Answer] = [],
         currentIndex: Int = 0,
         friends: [String] = []) {
        self.uid = uid
        self.name = name
        self.answers = answers
        self.currentIndex = currentIndex
        self.friends = friends
    }
}

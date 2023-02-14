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
    var currentIndex: Int
    var answers: [Answer]
    var friends: [String]
    
    init(uid: String = UUID().uuidString,
         currentIndex: Int = 0,
         answers: [Answer] = [],
         friends: [String] = []) {
        self.uid = uid
        self.currentIndex = currentIndex
        self.answers = answers
        self.friends = friends
    }
}

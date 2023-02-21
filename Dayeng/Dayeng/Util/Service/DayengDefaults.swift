//
//  DayengDefaults.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/14.
//

import Foundation

final class DayengDefaults {
    
    static let shared = DayengDefaults()
    
    // MARK: - Properties
    var user: User?
    var questions: [Question] = []
    
    // MARK: - LifeCycles
    private init() { }
    
    func addAnswer(_ answer: Answer) {
        user?.answers.append(answer)
        user?.currentIndex += 1
    }
    
    func addFriend(_ friend: String) {
        user?.friends.append(friend)
    }
    
}
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
        if user?.answers.count == user?.currentIndex {
            user?.currentIndex += 1
        }
        user?.answers.append(answer)
    }
    
    func editAnswer(_ answer: Answer, _ index: Int) {
        if let count = user?.answers.count, index >= count { return }
        user?.answers[index] = answer
    }
    
    func addFriend(_ friend: String) {
        user?.friends.append(friend)
    }
}

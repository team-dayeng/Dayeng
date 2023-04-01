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
    
    func editAnswer(_ answer: Answer, _ index: Int) {
        guard var user = user,
              index < user.answers.count else { return }
        user.answers[index] = answer
    }
    
    func addFriend(_ friend: String) {
        user?.friends.append(friend)
    }
    
    func getBonusQuestion() {
        user?.bonusQuestionDate = Date()
        user?.answers.append(Answer(date: Date().convertToString(format: "yyyy.MM.dd.E"),
                                    answer: " "))
        user?.currentIndex += 1
    }

}

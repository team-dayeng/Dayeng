//
//  DefaultMainUseCase.swift
//  Dayeng
//
//  Created by 조승기 on 2023/03/03.
//

import Foundation
import RxSwift

final class DefaultMainUseCase: MainUseCase {
    // MARK: - Dependency
    private let userRepository: UserRepository
    private let questionRepository: QuestionRepository
    private let disposeBag = DisposeBag()
    
    enum MainUseCaseError: Error {
        case noUserError
    }
    
    // MARK: - LifeCycle
    init(userRepository: UserRepository,
         questionRepository: QuestionRepository) {
        self.userRepository = userRepository
        self.questionRepository = questionRepository
    }
    
    // MARK: - Helper
    func fetchData() -> Observable<([(Question, Answer?)], Int?)> {
        Observable.zip(fetchQuestions(), fetchAnswers())
            .map { [weak self] questions, answers in
                (questions.enumerated().map { (index, question) in
                    let answer = answers.count > index ? answers[index] : nil
                    return (question, answer)
                }, self?.getBlurStartingIndex())
                
            }
    }
    
    func getBlurStartingIndex() -> Int? {
        guard let user = DayengDefaults.shared.user,
              user.currentIndex < DayengDefaults.shared.questions.count else {
            return nil
        }
        
        let today = Date().convertToString(format: "yyyy.MM.dd.E")
        let isAnswered = user.answers.last?.date == today
        let startIndex = isAnswered ? user.currentIndex : (user.currentIndex + 1)
        
        return startIndex
    }
    
    func fetchQuestions() -> Observable<[Question]> {
        if !DayengDefaults.shared.questions.isEmpty {
            return Observable.just(DayengDefaults.shared.questions)
        }
        
        return questionRepository.fetchAll()
            .map { questions in
                DayengDefaults.shared.questions = questions
                return questions
            }
    }
    
    func fetchAnswers() -> Observable<[Answer]> {
        fetchUser()
            .map { $0.answers }
    }
    
    func fetchUser() -> Observable<User> {
        guard let userID = UserDefaults.userID else { return Observable.error(MainUseCaseError.noUserError) }
        
        if let user = DayengDefaults.shared.user {
            return Observable.just(user)
        }
        
        return userRepository.fetchUser(userID: userID)
             .map { user in
                 DayengDefaults.shared.user = user
                 return user
             }
    }
}

//
//  DefaultMainUseCase.swift
//  Dayeng
//
//  Created by 조승기 on 2023/03/03.
//

import Foundation
import RxSwift

final class DefaultMainUseCase: MainUseCase {
    private let userRepository: UserRepository
    private let questionRepository: QuestionRepository
    private let disposeBag = DisposeBag()
    
    init(userRepository: UserRepository,
         questionRepository: QuestionRepository) {
        self.userRepository = userRepository
        self.questionRepository = questionRepository
    }
    
    enum MainUseCaseError: Error {
        case noUserError
    }
    
    func fetchData() -> Observable<[(Question, Answer?)]> {
        Observable.zip(fetchQuestions(), fetchAnswers())
            .map { questions, answers in
                questions.enumerated().map { (index, question) in
                    let answer = answers.count > index ? answers[index] : nil
                    return (question, answer)
                }
            }
    }
    
    func getBlurStartingIndex() -> Observable<Int?> {
        guard let user = DayengDefaults.shared.user else {
            return Observable.error(MainUseCaseError.noUserError)
        }
        if user.currentIndex >= DayengDefaults.shared.questions.count {
            return Observable.just(nil)
        }
        
        let today = Date().convertToString(format: "yyyy.MM.dd.E")
        let isAnswered = user.answers.last?.date == today
        let startIndex = isAnswered ? user.currentIndex : (user.currentIndex + 1)
        
        return Observable.just(startIndex)
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
            .disposed(by: disposeBag)
    }
    
    func fetchAnswers() -> Observable<[Answer]> {
        fetchUser()
            .map{ $0.answer }
    }
    
    func fetchUser() -> Observable<User> {
        guard let userID = UserDefaults.userID else { return MainUseCaseError.noUserError }
        
        if let user == DayengDefaults.shared.user {
            return Observable.just(user.answer)
        }
        
        return userRepository.fetchUser(userID: userID)
             .map { user in
                 DayengDefaults.shared.user = user
                 return user
             }
    }
}

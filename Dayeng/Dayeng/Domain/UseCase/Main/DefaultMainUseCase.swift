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
    private let ownerType: OwnerType
    var firstShowingIndex = BehaviorSubject<Int?>(value: nil)
    
    enum MainUseCaseError: Error {
        case noUserError
        case noSelfError
    }
    
    // MARK: - LifeCycle
    init(userRepository: UserRepository,
         questionRepository: QuestionRepository,
         ownerType: OwnerType
    ) {
        self.userRepository = userRepository
        self.questionRepository = questionRepository
        self.ownerType = ownerType
    }
    
    // MARK: - Helper
    func fetchOwnerType() -> OwnerType {
        return ownerType
    }
    
    func fetchData() -> Observable<([(Question, Answer?)], Int?)> {
        switch ownerType {
        case .mine:
            return Observable.zip(fetchQuestions(), fetchAnswers())
                .map { [weak self] questions, answers in
                    guard let self else { throw MainUseCaseError.noSelfError }
                    return (questions.enumerated().map { (index, question) in
                        let answer = answers.count > index ? answers[index] : nil
                        return (question, answer)
                    }, self.getBlurStartingIndex())
                }
        case .friend(let user):
            return Observable.zip(fetchQuestions(), Observable.of(user.answers))
                .map { questions, answers in
                    (answers.enumerated().map {
                        (questions[$0.offset], $0.element)
                    }, nil)
                }
        }
    }

    private func getBlurStartingIndex() -> Int? {
        guard let user = DayengDefaults.shared.user,
              user.currentIndex < DayengDefaults.shared.questions.count else {
            return nil
        }
        
        let today = Date().convertToString(format: "yyyy.MM.dd.E")
        let isAnswered = user.answers.last?.date == today
        let startIndex = isAnswered ? user.currentIndex : (user.currentIndex + 1)
        
        return startIndex
    }
    
    private func fetchQuestions() -> Observable<[Question]> {
        if !DayengDefaults.shared.questions.isEmpty {
            return Observable.just(DayengDefaults.shared.questions)
        }
        
        return questionRepository.fetchAll()
            .map { questions in
                DayengDefaults.shared.questions = questions
                return questions
            }
    }
    
    private func fetchAnswers() -> Observable<[Answer]> {
        fetchUser()
            .map { $0.answers }
    }
    
    private func fetchUser() -> Observable<User> {
        if let user = DayengDefaults.shared.user {
            return Observable.just(user)
        }
        
        guard let userID = UserDefaults.userID else { return Observable.error(MainUseCaseError.noUserError) }
        return userRepository.fetchUser(userID: userID)
            .map { user in
                DayengDefaults.shared.user = user
                return user
            }
    }
}

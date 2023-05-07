//
//  DefaultMainEditUseCase.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/03.
//

import Foundation
import RxSwift

final class DefaultMainEditUseCase: MainEditUseCase {
    // MARK: - Dependency
    private let userRepository: UserRepository
    private let index: Int
    
    enum EditError: Error, LocalizedError {
        case notEnterInput
        case noUserError
        var errorDescription: String? {
            switch self {
            case .notEnterInput:
                return NSLocalizedString("데잉을 입력해주세요!", comment: "")
            case .noUserError:
                return NSLocalizedString("회원 정보에 문제가 있습니다!", comment: "")
            }
        }
    }
    
    // MARK: - LifeCycle
    init(userRepository: UserRepository, index: Int) {
        self.userRepository = userRepository
        self.index = index
    }
    
    // MARK: - Helper
    func fetchQuestion() -> Observable<Question> {
        Observable.just(DayengDefaults.shared.questions[index])
    }
    
    func fetchAnswer() -> Observable<Answer?> {
        Observable<Answer?>.create { [weak self] observer in
            guard let self,
                  let user = DayengDefaults.shared.user,
                  (0..<user.answers.count) ~= self.index else {
                observer.onNext(nil)
                return Disposables.create()
            }
            observer.onNext(user.answers[self.index])
            return Disposables.create()
        }
    }
    
    func uploadAnswer(answer: String) -> Observable<Void> {
        if answer == "" || answer == "enter your answer." {
            return Observable.error(EditError.notEnterInput)
        }
        
        guard let user = DayengDefaults.shared.user else {
            return Observable.error(EditError.noUserError)
        }
        
        if user.answers.count < user.currentIndex {
            if user.currentIndex == index + 1 {
                return userRepository.uploadAnswer(answer: answer)
            }
        } else {
            if user.currentIndex == index {
                return userRepository.uploadAnswer(answer: answer)
            }
        }
        
        return userRepository.editAnswer(answer: answer, index: index)
    }
}

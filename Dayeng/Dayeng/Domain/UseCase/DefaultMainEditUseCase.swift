//
//  DefaultMainEditUseCase.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/03.
//

import Foundation
import RxSwift

final class DefaultMainEditUseCase {
    private let userRepository: UserRepository
    
    enum EditError: Error, LocalizedError {
        case notEnterInput
        var errorDescription: String? {
            switch self {
            case .notEnterInput:
                return NSLocalizedString("데잉을 입력해주세요!", comment: "")
            }
        }
    }
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    func uploadAnswer(answer: String) -> Observable<Void> {
        guard answer != "", answer != "enter your answer." else {
            return Observable.create {
                $0.onError(EditError.notEnterInput)
                return Disposables.create()
            }
        }
        return userRepository.uploadAnswer(answer: answer)
    }
}

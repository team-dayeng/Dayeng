//
//  DefaultCalendarUseCase.swift
//  Dayeng
//
//  Created by 배남석 on 2023/03/04.
//

import Foundation
import RxSwift

final class DefaultCalendarUseCase: CalendarUseCase {
    // MARK: - Properties
    private let userRepository: UserRepository
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycles
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    // MARK: - Helpers
}

//
//  CalendarUseCase.swift
//  Dayeng
//
//  Created by 배남석 on 2023/03/04.
//

import Foundation
import RxSwift

protocol CalendarUseCase {
    func fetchOwnerType() -> OwnerType
    func fetchAnswers() -> Observable<[Answer?]>
    func fetchCurrentIndex() -> Int
}

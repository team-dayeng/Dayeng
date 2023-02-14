//
//  QuestionRepository.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/11.
//

import Foundation
import RxSwift

protocol QuestionRepository {
    func fetchAll() -> Observable<[Question]?>
    func fetch(index: Int) -> Observable<Question>
}

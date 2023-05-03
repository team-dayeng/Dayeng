//
//  MainEditUseCase.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/28.
//

import Foundation
import RxSwift

protocol MainEditUseCase {
    func fetchQuestion() -> Observable<Question>
    func uploadAnswer(answer: String) -> Observable<Void>
}

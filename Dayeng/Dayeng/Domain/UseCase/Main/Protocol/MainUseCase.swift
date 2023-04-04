//
//  MainUseCase.swift
//  Dayeng
//
//  Created by 배남석 on 2023/03/31.
//

import Foundation
import RxSwift

protocol MainUseCase {
    func fetchQuestions() -> Observable<Void>
    func fetchUser() -> Observable<Void>
}

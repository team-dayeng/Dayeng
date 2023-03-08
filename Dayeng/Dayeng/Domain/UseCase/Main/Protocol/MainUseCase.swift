//
//  MainUseCase.swift
//  Dayeng
//
//  Created by 조승기 on 2023/03/03.
//

import Foundation
import RxSwift

protocol MainUseCase {
    func fetchData() -> Observable<[(Question, Answer?)]>
}

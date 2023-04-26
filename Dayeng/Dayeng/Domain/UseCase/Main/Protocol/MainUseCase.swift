//
//  MainUseCase.swift
//  Dayeng
//
//  Created by 조승기 on 2023/04/08.
//

import Foundation
import RxSwift

protocol MainUseCase {
    func fetchOwnerType() -> OwnerType
    func fetchData() -> Observable<([(Question, Answer?)], Int?)>
}

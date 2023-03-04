//
//  SettingUseCase.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/03/04.
//

import Foundation
import RxSwift

protocol SettingUseCase {
    func logout() -> Observable<Bool>
    func withdrawal() -> Observable<Bool>
}

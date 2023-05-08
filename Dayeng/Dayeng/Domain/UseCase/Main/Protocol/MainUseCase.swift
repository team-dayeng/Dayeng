//
//  MainUseCase.swift
//  Dayeng
//
//  Created by 조승기 on 2023/04/08.
//

import Foundation
import RxSwift

protocol MainUseCase {
    var firstShowingIndex: BehaviorSubject<Int?> { get set }
    func fetchOwnerType() -> OwnerType
    func fetchData() -> Observable<([(Question, Answer?)], Int?)>
    func isAvailableWatchAds() -> Observable<Bool>
    func updateUserAdsWatching()
}

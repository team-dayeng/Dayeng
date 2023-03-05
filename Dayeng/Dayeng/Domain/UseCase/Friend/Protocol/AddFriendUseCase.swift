//
//  AddFriendUseCase.swift
//  Dayeng
//
//  Created by 배남석 on 2023/03/02.
//

import Foundation
import RxSwift

protocol AddFriendUseCase {
    func addFriend(userID: String) -> Observable<Void>
}

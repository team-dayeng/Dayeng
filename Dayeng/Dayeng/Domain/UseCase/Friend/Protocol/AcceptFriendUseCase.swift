//
//  AcceptFriendUseCase.swift
//  Dayeng
//
//  Created by 배남석 on 2023/03/01.
//

import Foundation
import RxSwift

protocol AcceptFriendUseCase {
    func addFriend(userID: String) -> Observable<Void>
}

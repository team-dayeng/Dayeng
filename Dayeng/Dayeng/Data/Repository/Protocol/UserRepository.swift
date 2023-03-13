//
//  UserRepository.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/03.
//

import Foundation
import RxSwift

protocol UserRepository {
    func fetchUser(userID: String) -> Observable<User>
    func uploadUser(user: User) -> Observable<Void>
    func uploadAnswer(answer: String) -> Observable<Void>
    func existUser(userID: String) -> Observable<String>
    func fetchFriends(paths: [String]) -> Observable<[User]>
    func addFriend(user: User) -> Observable<Void>
}

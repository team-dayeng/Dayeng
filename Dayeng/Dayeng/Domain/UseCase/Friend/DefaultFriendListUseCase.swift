//
//  DefaultFriendListUseCase.swift
//  Dayeng
//
//  Created by 배남석 on 2023/03/02.
//

import Foundation
import RxSwift

final class DefaultFriendListUseCase: FriendListUseCase {
    // MARK: - Properties
    private let userRepository: UserRepository
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycles
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    // MARK: - Helpers
    func fetchFriends() -> Observable<[User]> {
        guard let user = DayengDefaults.shared.user else {
            return Observable.error(UserError.notExistCurrentUser)
        }
        return userRepository.fetchFriends(paths: user.friends)
            .map { [weak self] users in
                guard let self else { return [] }
                
                return self.sortedByKoreanFirst(users.compactMap { $0 })
            }
    }
    
    private func sortedByKoreanFirst(_ users: [User]) -> [User] {
        users.sorted {
            if $0.name < "A" && $1.name < "A" {
                return $0.name.localizedStandardCompare($1.name) == ComparisonResult.orderedAscending
            } else if $0.name >= "A" && $1.name >= "A" && $0.name <= "z" && $1.name <= "z" {
                return $0.name.localizedStandardCompare($1.name) == ComparisonResult.orderedAscending
            } else if $0.name > "z" && $1.name > "z" {
                return $0.name.localizedStandardCompare($1.name) == ComparisonResult.orderedAscending
            } else {
                let locale = Locale(identifier: "korea")
                return $0.name.compare($1.name, locale: locale) == ComparisonResult.orderedDescending
            }
        }
    }
}

//
//  DefaultAddFriendUseCase.swift
//  Dayeng
//
//  Created by 배남석 on 2023/03/02.
//

import Foundation
import RxSwift

final class DefaultAddFriendUseCase: AddFriendUseCase {
    enum AddFriendUseCase: Error {
        case alreadyFriendID
        case wrongUserID
        case myUserID
    }
    
    // MARK: - Properties
    private let linkBuilderService: LinkBuildService
    private let kakaoLinkBuildService: KakaoLinkBuildService
    private let userRepository: UserRepository
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycles
    init(userRepository: UserRepository,
         linkBuilderService: LinkBuildService,
         kakaoLinkBuildService: KakaoLinkBuildService) {
        self.userRepository = userRepository
        self.linkBuilderService = linkBuilderService
        self.kakaoLinkBuildService = kakaoLinkBuildService
    }
    
    // MARK: - Helpers
    func fetchDynamicLink() -> Observable<URL> {
        linkBuilderService.fetchDynamicLink()
    }
    
    func fetchKakaoLink() -> Observable<URL> {
        kakaoLinkBuildService.fetchKakaoLink()
    }
    
    func addFriend(userID: String) -> Observable<Void> {
        Observable.create { [weak self] observer in
            guard let self else { return Disposables.create() }
            self.userRepository.existUser(userID: userID)
                .subscribe(onNext: { (path: String) in
                    guard let user = DayengDefaults.shared.user else { return }
                    if user.friends.contains(path) {
                        observer.onError(AddFriendUseCase.alreadyFriendID)
                    } else if userID == user.uid {
                        observer.onError(AddFriendUseCase.myUserID)
                    } else {
                        DayengDefaults.shared.addFriend(path)
                        self.userRepository.addFriend(user: DayengDefaults.shared.user ?? user)
                            .bind(to: observer)
                            .disposed(by: self.disposeBag)
                    }
                }, onError: { _ in
                    observer.onError(AddFriendUseCase.wrongUserID)
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
}

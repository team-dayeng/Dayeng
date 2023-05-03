//
//  FriendListViewModel.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/03.
//

import Foundation
import RxSwift
import RxRelay

final class FriendListViewModel {
    
    private var disposeBag = DisposeBag()
    
    // MARK: - Input
    struct Input {
        var viewWillAppear: Observable<Void>
        var plusButtonDidTapped: Observable<Void>
        var friendIndexDidTapped: Observable<User?>
    }
    
    // MARK: - Output
    struct Output {
        var friends = PublishSubject<[User]>()
    }
    
    // MARK: - Property
    var useCase: FriendListUseCase
    
    // MARK: - Dependency
    var plusButtonDidTapped = PublishRelay<Void>()
    var friendIndexDidTapped = PublishRelay<User>()
    
    // MARK: - Lifecycles
    init(useCase: FriendListUseCase) {
        self.useCase = useCase
    }
    
    // MARK: - Helpers
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.viewWillAppear
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.useCase.fetchFriends()
                    .bind(to: output.friends)
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.plusButtonDidTapped
            .bind(to: plusButtonDidTapped)
            .disposed(by: disposeBag)
        
        input.friendIndexDidTapped
            .subscribe(onNext: { [weak self] user in
                guard let self, let user else { return }
                self.friendIndexDidTapped.accept(user)
            })
            .disposed(by: disposeBag)
        
        return output
    }
}

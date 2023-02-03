//
//  FriendListViewModel.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/03.
//

import Foundation
import RxSwift

final class FriendListViewModel {
    
    private var disposeBag = DisposeBag()
    
    // MARK: - Input
    struct Input {
        
        var plusButtonDidTapped: Observable<Void>
    }
    
    // MARK: - Output
    struct Output {
        var friends = BehaviorSubject<[User]>(value: [])
    }
    
    // MARK: - Dependency
    
    // MARK: - Lifecycles
    
    // MARK: - Helpers
    func transform(input: Input) -> Output {
        let output = Output()
        
        #warning("dummy")
        output.friends.onNext([User(uid: "옹이"),
                               User(uid: "멍이"),
                               User(uid: "남석12!")])
        let friends = [User(uid: "옹이"),
                       User(uid: "멍이"),
                       User(uid: "남석12!")]
        output.friends.onNext(friends)
        
        input.plusButtonDidTapped
            .subscribe(onNext: {
                print("plusButtonDidTapped")
                // TODO: 화면 전환
            })
            .disposed(by: disposeBag)
        
        return output
    }
}

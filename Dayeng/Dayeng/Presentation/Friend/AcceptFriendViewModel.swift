//
//  AcceptFriendViewModel.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/27.
//

import Foundation
import RxSwift
import RxRelay

final class AcceptFriendViewModel {
    // MARK: - Input
    struct Input {
        var addButtonDidTapped: Observable<Void>
    }
    
    // MARK: - Output
    struct Output {
        var addFriendResult = PublishSubject<Void>()
    }
    
    // MARK: - Properties
    var useCase: AcceptFriendUseCase
    var acceptFriendCode: String
    
    // MARK: - Dependency
    private var disposeBag = DisposeBag()
    
    // MARK: - LifeCycle
    init(useCase: AcceptFriendUseCase, acceptFriendCode: String) {
        self.useCase = useCase
        self.acceptFriendCode = acceptFriendCode
    }
    
    // MARK: - Helper
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.addButtonDidTapped
            .withUnretained(self)
            .flatMap { (onwer, _) in
                onwer.useCase.addFriend(userID: self.acceptFriendCode)
            }
            .bind(to: output.addFriendResult)
            .disposed(by: disposeBag)
        
        return output
    }
}

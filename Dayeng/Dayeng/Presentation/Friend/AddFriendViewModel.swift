//
//  AddFriendViewModel.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/27.
//

import Foundation
import RxSwift
import RxRelay

final class AddFriendViewModel {
    // MARK: - Input
    struct Input {
        var addButtonDidTapped: Observable<Void>
    }
    
    // MARK: - Output
    struct Output {
        
    }
    
    // MARK: - Dependency
    private let disposeBag = DisposeBag()
    
    // MARK: - LifeCycle
    
    // MARK: - Helper
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.addButtonDidTapped
            .subscribe(onNext: {
                // Firestore -> User 있는지 확인 -> User -> Friends에 삽입
            })
            .disposed(by: disposeBag)
        
        return output
    }
}

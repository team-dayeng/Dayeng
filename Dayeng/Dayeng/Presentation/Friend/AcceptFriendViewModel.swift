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
        
    }
    
    // MARK: - Dependency
    private var disposeBag = DisposeBag()
    var addButtonDidTapped = PublishRelay<Void>()
    
    // MARK: - LifeCycle
    
    // MARK: - Helper
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.addButtonDidTapped
            .bind(to: addButtonDidTapped)
            .disposed(by: disposeBag)
        
        return output
    }
}

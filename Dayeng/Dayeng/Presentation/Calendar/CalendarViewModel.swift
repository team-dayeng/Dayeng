//
//  CalendarViewModel.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/10.
//

import Foundation
import RxSwift
import RxRelay

final class CalendarViewModel {
    // MARK: - Input
    struct Input {
        var homeButtonDidTapped: Observable<Void>
    }
    
    // MARK: - Output
    struct Output {
        
    }
    
    // MARK: - Dependency
    private let disposeBag = DisposeBag()
    let homeButtonDidTapped = PublishRelay<Void>()
    
    // MARK: - LifeCycle
    
    // MARK: - Helper
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.homeButtonDidTapped
            .bind(to: homeButtonDidTapped)
            .disposed(by: disposeBag)
        
        return output
    }
}

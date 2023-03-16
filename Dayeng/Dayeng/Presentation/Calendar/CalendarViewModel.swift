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
        var viewDidLoad: Observable<Void>
        var homeButtonDidTapped: Observable<Void>
    }
    
    // MARK: - Output
    struct Output {
        var answers = PublishSubject<Void>()
    }
    
    // MARK: - Dependency
    private let useCase: CalendarUseCase
    private let disposeBag = DisposeBag()
    let homeButtonDidTapped = PublishRelay<Void>()
    
    // MARK: - LifeCycle
    init(useCase: CalendarUseCase) {
        self.useCase = useCase
    }
    
    // MARK: - Helper
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.homeButtonDidTapped
            .bind(to: homeButtonDidTapped)
            .disposed(by: disposeBag)
        
        return output
    }
}

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
        var cellDidTapped: Observable<Int>
    }
    
    // MARK: - Output
    struct Output {
        let ownerType: OwnerType
        let answers = ReplaySubject<[Answer?]>.create(bufferSize: 1)
        let currentIndex: Int
    }
    
    // MARK: - Dependency
    private let useCase: CalendarUseCase
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    let homeButtonDidTapped = PublishRelay<Void>()
    let cannotFindUserError = PublishSubject<Void>()
    let dayDidTapped = PublishRelay<Int>()
    
    // MARK: - LifeCycle
    init(useCase: CalendarUseCase) {
        self.useCase = useCase
    }
    
    // MARK: - Helper
    func transform(input: Input) -> Output {
        let output = Output(
            ownerType: useCase.fetchOwnerType(),
            currentIndex: useCase.fetchCurrentIndex()
        )
        
        useCase.fetchAnswers()
            .do(onError: { [weak self] _ in
                guard let self else { return }
                self.cannotFindUserError.onNext(())
            })
            .bind(to: output.answers)
            .disposed(by: disposeBag)
        
        input.homeButtonDidTapped
            .bind(to: homeButtonDidTapped)
            .disposed(by: disposeBag)
                
        input.cellDidTapped
                .filter { [weak self] index in
                    guard let self else { return false }
                    
                    if self.useCase.fetchOwnerType() != .mine && index >= self.useCase.fetchCurrentIndex() {
                        return false
                    }
                    return true
                }
            .bind(to: dayDidTapped)
            .disposed(by: disposeBag)
        return output
    }
}

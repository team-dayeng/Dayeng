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
        var cellDidTapped: Observable<Void>
    }
    
    // MARK: - Output
    struct Output {
        let ownerType: OwnerType
        let answers: Observable<[Answer?]>
        let currentIndex: Int
    }
    
    // MARK: - Dependency
    private let useCase: CalendarUseCase
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let ownerType: OwnerType
    let homeButtonDidTapped = PublishRelay<Void>()
    let cannotFindUserError = PublishSubject<Void>()
    
    // MARK: - LifeCycle
    init(useCase: CalendarUseCase, ownerType: OwnerType) {
        self.useCase = useCase
        self.ownerType = ownerType
    }
    
    // MARK: - Helper
    func transform(input: Input) -> Output {
        var answers = [Answer?]()
        
        switch ownerType {
        case .mine:
            if let user = DayengDefaults.shared.user {
                answers = user.answers
            } else {
                cannotFindUserError.onNext(())
            }
        case .friend(let user):
            answers = user.answers
        }
        
        let currentIndex = answers.count
        while DayengDefaults.shared.questions.count > answers.count {
            answers.append(nil)
        }
        
        let output = Output(
            ownerType: ownerType,
            answers: Observable.just(answers),
            currentIndex: currentIndex
        )
        
        input.homeButtonDidTapped
            .bind(to: homeButtonDidTapped)
            .disposed(by: disposeBag)
        
        return output
    }
}

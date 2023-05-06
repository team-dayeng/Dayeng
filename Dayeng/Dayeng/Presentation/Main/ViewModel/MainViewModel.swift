//
//  MainViewModel.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/02.
//

import Foundation
import RxSwift
import RxRelay

final class MainViewModel {
    // MARK: - Input
    struct Input {
        var viewWillAppear: Observable<Void>
        var friendButtonDidTapped: Observable<Void>
        var settingButtonDidTapped: Observable<Void>
        var calendarButtonDidTapped: Observable<Void>
        var editButtonDidTapped: Observable<Int>
    }
    // MARK: - Output
    struct Output {
        let ownerType: OwnerType
        var questionsAnswers = BehaviorRelay<[(Question, Answer?)]>(value: [])
        var startBluringIndex = BehaviorRelay<Int?>(value: nil)
        var firstShowingIndex = BehaviorRelay<Int?>(value: nil)
    }
    
    // MARK: - Properites
    private var disposeBag = DisposeBag()
    private let useCase: MainUseCase
    var friendButtonDidTapped = PublishRelay<Void>()
    var settingButtonDidTapped = PublishRelay<Void>()
    var calendarButtonDidTapped = PublishRelay<Void>()
    var editButtonDidTapped = PublishRelay<Int>()
    var cannotFindUserError = PublishSubject<Void>()
    
    // MARK: - LifeCycle
    init(useCase: MainUseCase) {
        self.useCase = useCase
    }
    
    // MARK: - Helper
    func transform(input: Input) -> Output {
        let output = Output(ownerType: useCase.fetchOwnerType())
        
        useCase.firstShowingIndex
            .bind(to: output.firstShowingIndex)
            .disposed(by: disposeBag)
        
        input.viewWillAppear
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                self.useCase.fetchData()
                    .subscribe(onNext: { data, index in
                        output.startBluringIndex.accept(index)
                        output.questionsAnswers.accept(data)
                    }, onError: { [weak self] _ in
                        guard let self else { return }
                        self.cannotFindUserError.onNext(())
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.friendButtonDidTapped
            .bind(to: friendButtonDidTapped)
            .disposed(by: disposeBag)
        
        input.settingButtonDidTapped
            .bind(to: settingButtonDidTapped)
            .disposed(by: disposeBag)
        
        input.calendarButtonDidTapped
            .bind(to: calendarButtonDidTapped)
            .disposed(by: disposeBag)
        
        input.editButtonDidTapped
            .bind(to: editButtonDidTapped)
            .disposed(by: disposeBag)
        
        return output
    }
}

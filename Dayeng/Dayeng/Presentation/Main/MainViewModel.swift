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
        var resetButtonDidTapped: Observable<Void>
        var friendButtonDidTapped: Observable<Void>
        var settingButtonDidTapped: Observable<Void>
        var calendarButtonDidTapped: Observable<Void>
        
    }
    // MARK: - Output
    struct Output {
        var successLoad = PublishSubject<Void>()
    }
    
    // MARK: - Properites
    var friendButtonDidTapped = PublishRelay<Void>()
    var settingButtonDidTapped = PublishRelay<Void>()
    var calendarButtonDidTapped = PublishRelay<Void>()
    
    // MARK: - Dependency
    var disposeBag = DisposeBag()
    private let useCase: MainUseCase
    
    // MARK: - LifeCycle
    init(useCase: MainUseCase) {
        self.useCase = useCase
    }
    
    // MARK: - Helper
    func transform(input: Input) -> Output {
        let output = Output()
        input.viewWillAppear
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                Observable.zip(
                    self.useCase.fetchUser(),
                    self.useCase.fetchQuestions()
                )
                .map { _ in }
                .bind(to: output.successLoad)
                .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.resetButtonDidTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                print("tapped reset button")
            }).disposed(by: disposeBag)
        
        input.friendButtonDidTapped
            .bind(to: friendButtonDidTapped)
            .disposed(by: disposeBag)
        
        input.settingButtonDidTapped
            .bind(to: settingButtonDidTapped)
            .disposed(by: disposeBag)
        
        input.calendarButtonDidTapped
            .bind(to: calendarButtonDidTapped)
            .disposed(by: disposeBag)
        return output
    }
}

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
        var resetButtonDidTapped: Observable<Void>
        var friendButtonDidTapped: Observable<Void>
        var settingButtonDidTapped: Observable<Void>
        var calendarButtonDidTapped: Observable<Void>
        
    }
    // MARK: - Output
    struct Output {
        
    }
    // MARK: - Dependency
    var disposeBag = DisposeBag()
    var friendButtonDidTapped = PublishRelay<Void>()
    var settingButtonDidTapped = PublishRelay<Void>()
    var calendarButtonDidTapped = PublishRelay<Void>()
    
    // MARK: - LifeCycle
    
    // MARK: - Helper
    func transform(input: Input) -> Output {
        let output = Output()
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

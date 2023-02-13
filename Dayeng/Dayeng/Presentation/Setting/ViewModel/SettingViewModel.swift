//
//  SettingViewModel.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/06.
//

import Foundation
import RxSwift

final class SettingViewModel {
    // MARK: - Input
    struct Input {
        var alarmCellTapped: Observable<Void>
    }
    // MARK: - Output
    struct Output {
        var transformAlarm = PublishSubject<Void>()
    }
    // MARK: - Dependency
    var disposeBag = DisposeBag()
    let backButtonDidTapped = PublishSubject<Void>()
    
    // MARK: - LifeCycle
    
    // MARK: - Helper
    func transform(input: Input) -> Output {
        let output = Output()
        input.alarmCellTapped
            .subscribe(onNext: { [weak self] in
                output.transformAlarm.onNext(())
                
            }).disposed(by: disposeBag)
        return output
    }
}

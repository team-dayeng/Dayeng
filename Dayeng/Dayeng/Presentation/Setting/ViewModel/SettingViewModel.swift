//
//  SettingViewModel.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/06.
//

import Foundation
import RxSwift
import RxRelay

final class SettingViewModel {
    // MARK: - Input
    struct Input {
        var alarmCellTapped: Observable<Void>
    }
    // MARK: - Output
    struct Output {
        
    }
    // MARK: - Dependency
    var disposeBag = DisposeBag()
    let backButtonDidTapped = PublishSubject<Void>()
    let alarmCellDidTapped = PublishRelay<Void>()
    // MARK: - LifeCycle
    
    // MARK: - Helper
    func transform(input: Input) -> Output {
        let output = Output()
        input.alarmCellTapped
            .bind(to: alarmCellDidTapped)
            .disposed(by: disposeBag)
        return output
    }
}

//
//  AlarmSettingViewModel.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/10.
//

import Foundation
import RxSwift
import RxRelay

final class AlarmSettingViewModel {
    // MARK: - Input
    struct Input {
        var registButtonDidTapped: Observable<Date>
        var daysOfWeekDidTapped: Observable<Void>
    }
    // MARK: - Output
    struct Output {
        var dayList = PublishRelay<String>()
        var date = PublishRelay<Date>()
    }
    // MARK: - Dependency
    var disposeBag = DisposeBag()
    let useCase: AlrarmSettingUseCase
    // MARK: - LifeCycle
    init(useCase: AlrarmSettingUseCase) {
        self.useCase = useCase
    }
    
    // MARK: - Helper
    func transform(input: Input) -> Output {
        let output = Output()
        input.daysOfWeekDidTapped
            .subscribe(onNext: {
                // 코디네이터로 변경
            }).disposed(by: disposeBag)
        
        input.registButtonDidTapped
            .subscribe(onNext: { date in
                
            }).disposed(by: disposeBag)
        return output
    }
}

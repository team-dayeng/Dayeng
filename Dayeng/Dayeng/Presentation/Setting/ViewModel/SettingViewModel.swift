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
        var cellDidTapped: Observable<IndexPath>
    }
    // MARK: - Output
    struct Output {
        
    }
    // MARK: - Dependency
    var disposeBag = DisposeBag()
    var alarmCellDidTapped = PublishRelay<Void>()
    
    // MARK: - LifeCycle
    
    // MARK: - Helper
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.cellDidTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                let section = $0.section
                let row = $0.row
                
                switch (section, row) {
                case (0,0):
                    self.alarmCellDidTapped.accept(())
                case (1,0):
                    break
                case (1,1):
                    break
                case (2,0):
                    break
                case (2,1):
                    break
                case (2,2):
                    break
                case (2,3):
                    break
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        return output
    }
}

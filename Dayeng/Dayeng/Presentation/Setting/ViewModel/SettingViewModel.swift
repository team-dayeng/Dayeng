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
        var messageUIError = PublishRelay<Void>()
    }
    // MARK: - Dependency
    var disposeBag = DisposeBag()
    var alarmCellDidTapped = PublishRelay<Void>()
    var openSourceCellDidTapped = PublishRelay<Void>()
    var aboutCellDidTapped = PublishRelay<Void>()
    var messageUICellDidTapped = PublishRelay<MessageUIType>()
    var messageUIError = PublishRelay<Void>()
    
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
                case (0, 0):
                    self.alarmCellDidTapped.accept(())
                case (1, 0):
                    break
                case (1, 1):
                    break
                case (2, 0): // 추천
                    self.messageUICellDidTapped.accept(.recommendQuestion)
                case (2, 1): // 문의
                    self.messageUICellDidTapped.accept(.inquiry)
                case (2, 2):
                    self.openSourceCellDidTapped.accept(())
                case (2, 3):
                    self.aboutCellDidTapped.accept(())
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        messageUIError
            .subscribe(onNext: { _ in
            output.messageUIError.accept(())
        }).disposed(by: disposeBag)
        
        return output
    }
}

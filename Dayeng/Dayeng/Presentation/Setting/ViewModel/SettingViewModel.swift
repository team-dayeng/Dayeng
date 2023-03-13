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
        var logoutDidTapped: Observable<Void>
        var withdrawalDidTapped: Observable<Void>
    }
    
    // MARK: - Output
    struct Output {
        var showMailComposeViewController = PublishRelay<MessageUIType>()
        var logoutFailed = PublishRelay<Void>()
        var withdrawalFailed = PublishRelay<Void>()
    }
    
    // MARK: - Properties
    private var disposeBag = DisposeBag()
    var alarmCellDidTapped = PublishRelay<Void>()
    var openSourceCellDidTapped = PublishRelay<Void>()
    var aboutCellDidTapped = PublishRelay<Void>()
    var logoutSuccess = PublishRelay<Void>()
    var withdrawalSuccess = PublishRelay<Void>()
    
    
    // MARK: - Dependency
    private let useCase: SettingUseCase
    
    // MARK: - LifeCycle
    init(useCase: SettingUseCase) {
        self.useCase = useCase
    }
    
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
                case (1, 1): // 회원 탈퇴
                    break
                case (2, 0): // 추천
                    output.showMailComposeViewController.accept(.recommendQuestion)
                case (2, 1): // 문의
                    output.showMailComposeViewController.accept(.inquiry)
                case (2, 2):
                    self.openSourceCellDidTapped.accept(())
                case (2, 3):
                    self.aboutCellDidTapped.accept(())
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        input.logoutDidTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.useCase.logout()
                    .subscribe(onNext: { [weak self] result in
                        guard let self else { return }
                        if result {
                            self.logoutSuccess.accept(())
                        } else {
                            output.logoutFailed.accept(())
                        }
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.withdrawalDidTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.useCase.withdrawal()
                    .subscribe(onNext: { [weak self] result in
                        guard let self else { return }
                        if result {
                            self.withdrawalSuccess.accept(())
                        } else {
                            output.withdrawalFailed.accept(())
                        }
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        return output
    }
}

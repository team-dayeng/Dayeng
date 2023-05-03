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
        var requestFailed = PublishRelay<AlertMessageType>()
    }
    
    // MARK: - Properties
    private var disposeBag = DisposeBag()
    var alarmCellDidTapped = PublishRelay<Void>()
    var openSourceCellDidTapped = PublishRelay<Void>()
    var aboutCellDidTapped = PublishRelay<Void>()
    var showLoginViewController = PublishRelay<AlertMessageType>()
    
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
                self.useCase.signOut()
                    .subscribe(onSuccess: { [weak self] _ in
                        guard let self else { return }
                        self.showLoginViewController.accept(.logoutSuccess)
                    }, onFailure: { error in
                        self.showLoginViewController.accept(.logoutFail(error: error))
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.withdrawalDidTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.useCase.withdrawal()
                    .subscribe(onSuccess: { [weak self] _ in
                        guard let self else { return }
                        self.showLoginViewController.accept(.withdrawalSuccess)
                    }, onFailure: { error in
                        self.showLoginViewController.accept(.withdrawalFail(error: error))
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        return output
    }
}

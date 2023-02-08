//
//  MainEditViewModel.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/03.
//

import Foundation
import RxSwift

final class MainEditViewModel {
    // MARK: - Input
    struct Input {
        var submitButtonTapped: Observable<Void>
        var answerText: Observable<String>
    }
    
    // MARK: - Output
    struct Output {
        var submitResult = PublishSubject<Error?>()
    }
    
    // MARK: - Dependency
    var disposeBag = DisposeBag()
    let useCase: DefaultMainEditUseCase
    
    // MARK: - LifeCycle
    init(useCase: DefaultMainEditUseCase) {
        self.useCase = useCase
    }
    
    // MARK: - Helper
    func transform(input: Input) -> Output {
        let output = Output()
        input.submitButtonTapped.withLatestFrom(input.answerText)
            .subscribe(onNext: { [weak self] answer in
                guard let self else { return }
                #warning("user로 변경")
                self.useCase.uploadAnswer(userID: "newuser", index: 3, answer: answer)
                    .subscribe(onNext: {
                        output.submitResult.onNext(nil)
                    }, onError: { error in
                        output.submitResult.onNext(error)
                    }).disposed(by: self.disposeBag)
                
            }).disposed(by: disposeBag)
        return output
    }
}

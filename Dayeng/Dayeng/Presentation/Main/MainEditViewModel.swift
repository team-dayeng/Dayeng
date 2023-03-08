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
        var viewDidLoad: Observable<Void>
    }
    
    // MARK: - Output
    struct Output {
        var submitResult = PublishSubject<Error?>()
        var question = ReplaySubject<Question>.create(bufferSize: 1)
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
        
        useCase.fetchQuestion()
            .bind(to: output.question)
            .disposed(by: disposeBag)
        
        useCase.fetchAnswer()
        
        
        input.submitButtonTapped.withLatestFrom(input.answerText)
            .subscribe(onNext: { [weak self] answer in
                guard let self else { return }
                #warning("user로 변경")
                self.useCase.uploadAnswer(answer: answer)
                    .subscribe(onNext: {
                        output.submitResult.onNext(nil)
                    }, onError: { error in
                        output.submitResult.onNext(error)
                    }).disposed(by: self.disposeBag)
                
            }).disposed(by: disposeBag)
        return output
    }
}

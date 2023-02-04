//
//  MainViewModel.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/02.
//

import Foundation
import RxSwift

final class MainViewModel {
    // MARK: - Input
    struct Input {
        var resetButtonTapped: Observable<Void>
    }
    // MARK: - Output
    struct Output {
        
    }
    // MARK: - Dependency
    var disposeBag = DisposeBag()
    // MARK: - LifeCycle
    
    // MARK: - Helper
    func transform(input: Input) -> Output {
        let output = Output()
        input.resetButtonTapped
            .subscribe(onNext: {
                
            }).disposed(by: disposeBag)
        return output
    }
}

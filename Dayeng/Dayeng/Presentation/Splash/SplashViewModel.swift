//
//  SplashViewModel.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/10.
//

import Foundation
import RxSwift
import RxRelay

final class SplashViewModel {
    // MARK: - Input
    struct Input {
        var animationDidStarted: Observable<Void>
    }
    
    // MARK: - Output
    struct Output {
        
    }
    
    // MARK: - Dependency
    var disposeBag = DisposeBag()
    private weak var coordinator: AppCoordinator?
    private let firestoreService = DefaultFirestoreDatabaseService()
    let dataDidLoaded = PublishRelay<Void>()
    
    // MARK: - Lifecycles
    
    // MARK: - Helpers
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.animationDidStarted
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.firestoreService.fetch(collection: "questions")
                    .subscribe(onNext: { (result: [[String: String]]) in
                        print(result)
                        self.dataDidLoaded.accept(())
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        return output
    }
}

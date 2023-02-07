//
//  SplashViewModel.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/07.
//

import Foundation
import RxSwift
import RxRelay

final class SplashViewModel {
    // MARK: - Input
    struct Input {
        var animationStartEvent: Observable<Void>
    }
    
    // MARK: - Output
    struct Output {
        
    }
    
    // MARK: - Dependency
    var disposeBag = DisposeBag()
    private weak var coordinator: AppCoordinator?
    private let firestoreService = DefaultFirestoreDatabaseService()
    let sibalEvent = PublishRelay<Void>()
    
    // MARK: - Lifecycles
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }
    
    // MARK: - Helpers
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.animationStartEvent
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.firestoreService.fetch(api: .questions)
                    .subscribe(onNext: { (result: [String: String]) in
                        print(result)
                        self.coordinator?.showMainViewController()
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        return output
    }
}

//
//  SplashViewModel.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/07.
//

import Foundation
import RxSwift

final class SplashViewModel {
    // MARK: - Input
    struct Input {
        
    }
    
    // MARK: - Output
    struct Output {
        
    }
    
    // MARK: - Dependency
    var disposeBag = DisposeBag()
    private weak var coordinator: AppCoordinator?
    
    // MARK: - Lifecycles
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }
    
    // MARK: - Helpers
    func transform(input: Input) -> Output {
        let output = Output()
        
        return output
    }
}

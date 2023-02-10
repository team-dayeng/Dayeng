//
//  CalendarViewModel.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/10.
//

import Foundation
import RxSwift
import RxRelay

final class CalendarViewModel {
    // MARK: - Input
    struct Input {
        
    }
    
    // MARK: - Output
    struct Output {
        
    }
    
    // MARK: - Dependency
    private let ownerType: OwnerType
    private let disposeBag = DisposeBag()
    private let tappedBackButton = PublishRelay<Void>()
    
    
    // MARK: - LifeCycle
    init(ownerType: OwnerType) {
        self.ownerType = ownerType
    }
    
    // MARK: - Helper
    func transform(input: Input) -> Output {
        let output = Output()
        
        return output
    }
}

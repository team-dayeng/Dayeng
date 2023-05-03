//
//  AddFriendViewModel.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/27.
//

import Foundation
import RxSwift
import RxRelay

final class AddFriendViewModel {
    // MARK: - Input
    struct Input {
        var addButtonDidTapped: Observable<String>
        var shareButtonDidTapped: Observable<Void>
    }
    
    // MARK: - Output
    struct Output {
        var shareButtonResult = PublishRelay<URL>()
        var addButtonSuccess = PublishSubject<Void>()
        var addButtonError = PublishSubject<String>()
    }
    
    // MARK: - Dependency
    private let disposeBag = DisposeBag()
    private let useCase: AddFriendUseCase
    
    // MARK: - LifeCycle
    init(useCase: AddFriendUseCase) {
        self.useCase = useCase
    }
    
    // MARK: - Helper
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.addButtonDidTapped
            .subscribe(onNext: { [weak self] text in
                guard let self else { return }
                print(text)
                self.useCase.addFriend(userID: text)
                    .subscribe(onNext: {
                        output.addButtonSuccess.onNext(())
                    }, onError: { error in
                        output.addButtonError.onNext("\(error)")
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.shareButtonDidTapped
            .withUnretained(self)
            .flatMap { (owner, _) in
                owner.useCase.fetchDynamicLink()
            }
            .bind(to: output.shareButtonResult)
            .disposed(by: disposeBag)
        
        return output
    }
}

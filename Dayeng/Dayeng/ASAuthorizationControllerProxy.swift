//
//  ASAuthorizationControllerProxy.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/19.
//

import AuthenticationServices
import RxSwift
import RxCocoa

extension ASAuthorizationController: HasDelegate {
    public typealias Delegate = ASAuthorizationControllerDelegate
}

@available(iOS 13.0, *)
final class ASAuthorizationControllerProxy:
    DelegateProxy<ASAuthorizationController, ASAuthorizationControllerDelegate>,
    DelegateProxyType,
    ASAuthorizationControllerDelegate,
    ASAuthorizationControllerPresentationContextProviding {
    
    var presentationWindow = UIWindow()
    
    init(controller: ASAuthorizationController) {
        super.init(
            parentObject: controller,
            delegateProxy: ASAuthorizationControllerProxy.self
        )
    }
    
    // MARK: - DelegateProxyType
    
    static func registerKnownImplementations() {
        register { authorizationController -> ASAuthorizationControllerProxy in
            ASAuthorizationControllerProxy(controller: authorizationController)
        }
    }
    
    // MARK: - Proxy Subject
    lazy var didComplete = PublishSubject<ASAuthorization>()
    
    // MARK: - ASAuthorizationControllerDelegate
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        didComplete.onNext(authorization)
        didComplete.onCompleted()
    }
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        didComplete.onError(error)
    }
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        presentationWindow
    }
    
    // MARK: - Completed
    
    deinit {
        didComplete.onCompleted()
    }
}

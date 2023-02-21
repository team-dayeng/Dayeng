//
//  AuthenticationServices+Rx.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/19.
//

import AuthenticationServices
import RxSwift

@available(iOS 13.0, *)
extension Reactive where Base: ASAuthorizationAppleIDProvider {
    
    func login(
        scope: [ASAuthorization.Scope]? = nil,
        nonce: String?
    ) -> Observable<ASAuthorization> {

        let request = base.createRequest()
        request.requestedScopes = scope
        request.nonce = nonce
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        let proxy = ASAuthorizationControllerProxy.proxy(for: controller)
        
        controller.presentationContextProvider = proxy
        controller.performRequests()
        
        return proxy.didComplete
    }
}

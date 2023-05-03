//
//  DefaultLinkBuildService.swift
//  Dayeng
//
//  Created by 배남석 on 2023/03/11.
//

import Foundation
import FirebaseDynamicLinks
import RxSwift

final class DefaultLinkBuildService: LinkBuildService {
    enum LinkBuildServiceError: Error {
        case wrongURL
    }
    
    func setuplinkBuilder() -> DynamicLinkComponents {
        let dynamicLinksDomainURIPrefix = "https://dayeng.page.link"
        guard let user = DayengDefaults.shared.user else { return DynamicLinkComponents() }
        
        var components = URLComponents(string: "https://dayeng.page.link/inviteFriend")
        let codeQuery = URLQueryItem(name: "code", value: user.uid)
        let nameQuery = URLQueryItem(name: "name", value: user.name)
        components?.queryItems = [codeQuery, nameQuery]
        
        guard let components = components,
              let link = components.url,
              let linkBuilder = DynamicLinkComponents(
                link: link,
                domainURIPrefix: dynamicLinksDomainURIPrefix
              ) else { return DynamicLinkComponents()}
       
        linkBuilder.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.dayeng.dayeng")
        linkBuilder.iOSParameters?.appStoreID = "123456789"
        linkBuilder.navigationInfoParameters = DynamicLinkNavigationInfoParameters()
        linkBuilder.navigationInfoParameters?.isForcedRedirectEnabled = true
        
        return linkBuilder
    }
    
    func fetchDynamicLink() -> Observable<URL> {
        Observable.create { observer in
            let linkBuilder = self.setuplinkBuilder()
            linkBuilder.shorten { url, _, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                guard let url = url else {
                    observer.onError(LinkBuildServiceError.wrongURL)
                    return
                }
                observer.onNext(url)
            }
            
            return Disposables.create()
        }
    }
}

//
//  DefaultKakaoLinkBuildService.swift
//  Dayeng
//
//  Created by 배남석 on 2023/05/06.
//

import Foundation
import KakaoSDKTemplate
import KakaoSDKShare
import KakaoSDKCommon
import RxSwift

final class DefaultKakaoLinkBuildService: KakaoLinkBuildService {
    enum KakaoLinkBuildError: Error {
        case kakaoAppNotExist
    }
    
    func fetchKakaoLink() -> Observable<URL> {
        Observable.create { observer in
            if ShareApi.isKakaoTalkSharingAvailable() {
                guard let userID = UserDefaults.userID,
                      let userName = UserDefaults.userName else { return Disposables.create() }
                let appLink = Link(iosExecutionParams: ["code": "\(userID)",
                                                        "name": "\(userName)"])
                let button = Button(title: "앱에서 보기", link: appLink)
                
                let first = "https://firebasestorage.googleapis.com/v0/b/team-dayeng.appspot.com/o/%"
                let second = "E1%84%8B%E1%85%A2%E1%86%B8%E1%84%85%E1%85%A9%E1%84%80%E1%85%A9.png?"
                let url = first + second + "alt=media&token=a39182a6-d764-41e3-8f13-194fcc3544d3"
                
                let content = Content(title: "Dayeng에서 초대장이 도착했습니다.",
                                      imageUrl: URL(string: url)!,
                                      link: appLink)
                let template = FeedTemplate(content: content, buttons: [button])
                if let templateJsonData = (try? SdkJSONEncoder.custom.encode(template)) {
                    if let templateJsonObject = SdkUtils.toJsonObject(templateJsonData) {
                        ShareApi.shared.shareDefault(templateObject: templateJsonObject) { (linkResult, error) in
                            if let error = error {
                                observer.onError(error)
                            } else {
                                guard let linkResult = linkResult else { return }
                                observer.onNext(linkResult.url)
                            }
                        }
                    }
                }
            } else {
                observer.onError(KakaoLinkBuildError.kakaoAppNotExist)
            }
            return Disposables.create()
                
        }
    }
}

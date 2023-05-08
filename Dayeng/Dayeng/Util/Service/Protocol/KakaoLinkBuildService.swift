//
//  KakaoLinkBuildService.swift
//  Dayeng
//
//  Created by 배남석 on 2023/05/06.
//

import Foundation
import RxSwift

protocol KakaoLinkBuildService {
    func fetchKakaoLink() -> Observable<URL>
}

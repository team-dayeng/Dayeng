//
//  LinkBuildService.swift
//  Dayeng
//
//  Created by 배남석 on 2023/03/11.
//

import Foundation
import RxSwift
import FirebaseDynamicLinks

protocol LinkBuildService {
    func setuplinkBuilder() -> DynamicLinkComponents
    func fetchDynamicLink() -> Observable<URL>
}

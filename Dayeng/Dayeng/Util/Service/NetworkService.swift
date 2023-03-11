//
//  NetworkService.swift
//  Dayeng
//
//  Created by 조승기 on 2023/03/11.
//

import Foundation
import RxSwift

protocol NetworkService {
    func request(
        url: URL,
        method: HTTPMethod,
        parameters: [String: Any]?,
        headers: [String: String]?
    ) -> Observable<Data?>
}

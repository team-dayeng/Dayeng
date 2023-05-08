//
//  AdMessageType.swift
//  Dayeng
//
//  Created by 배남석 on 2023/05/08.
//

import Foundation

enum AdMessageType {
    case leftQuestion
    case notLoadAd
    
    var message: String {
        switch self {
        case .leftQuestion:
            return "답변하지 않은 질문이 있습니다."
        case .notLoadAd:
            return "광고를 이용할 수 없습니다."
        }
    }
}

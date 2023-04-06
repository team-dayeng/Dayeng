//
//  LocaleType.swift
//  Dayeng
//
//  Created by 배남석 on 2023/04/03.
//

import Foundation

enum LocaleType {
    case korea
    
    var text: String {
        switch self {
        case .korea:
            return "ko-KR"
        }
    }
}

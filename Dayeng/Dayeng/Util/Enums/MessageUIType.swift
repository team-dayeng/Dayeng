//
//  MessageUIType.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/16.
//

import Foundation

enum MessageUIType {
    case recommendQuestion
    case inquiry
    
    var recipient: String {
        "beenzino@kookmin.ac.kr"
    }
    
    var subject: String {
        switch self {
        case .recommendQuestion:
            return "데잉에게 질문 추천하기"
        case .inquiry:
            return "데잉에게 궁금해요"
        }
    }
    
    var messageBody: String {
        switch self {
        case .recommendQuestion:
            return """
데잉에게 질문을 추천해주세요!
심의에 걸쳐 나올 수도 있습니다!

질문 내용(English) :
질문 내용(한글) :
"""
        case .inquiry:
            return """
데잉에게 궁금한 점이 있다면 적어주세요!

내용 :
"""
        }
    }
}

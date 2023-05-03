//
//  ToastType.swift
//  Dayeng
//
//  Created by 배남석 on 2023/03/02.
//

import Foundation

enum ToastType {
    case clipboard
    
    var title: String {
        switch self {
        case .clipboard:
            return "복사 완료하였습니다."
        }
    }
}

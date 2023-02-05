//
//  AuthType.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/01.
//

import UIKit

enum AuthType {
    case apple
    case kakao
    
    var logoImage: UIImage? {
        switch self {
        case .apple: return UIImage(systemName: "applelogo")
        case .kakao: return UIImage(named: "Kakao")
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .apple: return .white
        case .kakao: return UIColor(hexString: "FEE500")
        }
    }
    
    var loginMessage: String {
        switch self {
        case .apple: return "Apple로 시작하기"
        case .kakao: return "카카오로 시작하기"
        }
    }
}

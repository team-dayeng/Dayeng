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
    
    var logoImageName: UIImage? {
        switch self {
        case .apple: return UIImage(systemName: "applelogo")
        case .kakao: return UIImage(named: "Kakao")
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .apple: return .white
        case .kakao: return UIColor(red: 250, green: 230, blue: 77)
        }
    }
    
    var loginMessage: String {
        switch self {
        case .apple: return "Apple로 로그인"
        case .kakao: return "KaKao로 로그인"
        }
    }
}

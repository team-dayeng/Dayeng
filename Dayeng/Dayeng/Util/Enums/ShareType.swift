//
//  ShareType.swift
//  Dayeng
//
//  Created by 배남석 on 2023/05/05.
//

import UIKit

enum ShareType {
    case base
    case kakao
    
    var logoImage: UIImage? {
        switch self {
        case .base: return UIImage(systemName: "square.and.arrow.up")
        case .kakao: return UIImage(named: "Kakao")
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .base: return UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        case .kakao: return UIColor(hexString: "FEE500")
        }
    }
    
    var shareMessage: String {
        switch self {
        case .base: return "공유링크 복사하기"
        case .kakao: return "친구에게 공유하기"
        }
    }
}

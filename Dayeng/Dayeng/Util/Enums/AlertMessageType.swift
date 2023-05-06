//
//  AlertMessageType.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/03/12.
//

import Foundation

enum AlertMessageType {
    case logoutSuccess
    case withdrawalSuccess
    case loginFail(error: Error)
    case logoutFail(error: Error)
    case withdrawalFail(error: Error)
    case cannotFindUser
    case stopEdit
    
    var title: String {
        switch self {
        case .logoutSuccess:
            return "로그아웃 되었습니다."
        case .withdrawalSuccess:
            return "탈퇴 되었습니다."
        case .loginFail:
            return "로그인에 실패했습니다. 다시 시도해주세요"
        case .logoutFail:
            return "로그아웃에 실패했습니다. 로그인 후 다시 시도해주세요"
        case .withdrawalFail:
            return "탈퇴에 실패했습니다. 다시 시도해주세요"
        case .cannotFindUser:
            return "사용자를 찾을 수 없습니다."
        case .stopEdit:
            return "작성을 그만두시겠습니까?"
        }
    }
    
    var message: String? {
        switch self {
        case .loginFail(let error):
            return error.localizedDescription
        case .logoutFail(let error):
            return error.localizedDescription
        case .withdrawalFail(let error):
            return error.localizedDescription
        case .cannotFindUser:
            return "로그인 후 다시 시도해주세요."
        case .stopEdit:
            return "변경 사항은 저장되지 않습니다."
        default:
            return nil
        }
    }
    
    var rightActionTitle: String? {
        switch self {
        case .stopEdit:
            return "나가기"
        default:
            return nil
        }
    }
}

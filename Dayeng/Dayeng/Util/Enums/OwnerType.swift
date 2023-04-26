//
//  OwnerType.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/01.
//

import Foundation

enum OwnerType: Equatable {
    case mine
    case friend(user: User)
    
    
    static func == (lhs: OwnerType, rhs: OwnerType) -> Bool {
        switch (lhs, rhs) {
        case (.mine, .mine):
            return true
        case (.friend, .friend):
            return true
        default:
            return false
        }
    }
}

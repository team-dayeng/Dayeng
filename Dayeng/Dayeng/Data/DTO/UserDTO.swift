//
//  UserDTO.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/03.
//

import Foundation

struct UserDTO: Codable {
    var answers: [String: String]?
    var currentIndex: Int?
    var friends: [String]?
}

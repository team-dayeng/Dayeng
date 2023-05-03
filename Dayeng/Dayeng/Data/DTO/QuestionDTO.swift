//
//  QuestionDTO.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/09.
//

import Foundation

struct QuestionDTO: Codable {
    let english: String
    let korean: String
    
    func toDomain() -> Question {
        Question(english: english, korean: korean)
    }
}

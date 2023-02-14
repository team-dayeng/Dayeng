//
//  AnswerDTO.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/11.
//

import Foundation

struct AnswerDTO: Codable {
    let date: String
    var answer: String
    
    func toDomain() -> Answer {
        Answer(date: date, answer: answer)
    }
}

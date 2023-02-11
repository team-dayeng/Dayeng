//
//  DefaultQuestionRepository.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/11.
//

import Foundation
import RxSwift

final class DefaultQuestionRepository: QuestionRepository {
    
    func fetchAll() -> Observable<[Question]> {
        DefaultFirestoreDatabaseService()
            .fetch(collection: "questions")
            .map { (questions: [QuestionDTO]) in
                DefaultDayengCacheService.shared.write("questions", data: questions)
                return questions.map { $0.toDomain() }
            }
    }
    
    func fetch(index: Int) -> Observable<Question> {
        DefaultFirestoreDatabaseService()
            .fetch(collection: "questions", document: String(index))
            .map { (question: QuestionDTO) in
                question.toDomain()
            }
    }
}

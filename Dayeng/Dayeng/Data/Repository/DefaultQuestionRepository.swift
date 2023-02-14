//
//  DefaultQuestionRepository.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/11.
//

import Foundation
import RxSwift

final class DefaultQuestionRepository: QuestionRepository {
    
    private let firestoreService: FirestoreDatabaseService
    
    init(firestoreService: FirestoreDatabaseService) {
        self.firestoreService = firestoreService
    }
    
    func fetchAll() -> Observable<[Question]> {
        firestoreService.fetch(collection: "questions")
            .map { (questions: [QuestionDTO]) in
                return questions.map { $0.toDomain() }
            }
    }
    
    func fetch(index: Int) -> Observable<Question> {
        firestoreService.fetch(collection: "questions", document: String(index))
            .map { (question: QuestionDTO) in
                question.toDomain()
            }
    }
}

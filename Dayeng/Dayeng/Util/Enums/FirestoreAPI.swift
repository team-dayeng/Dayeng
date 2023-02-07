//
//  FirestoreAPI.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/03.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum FirestoreAPI {
    case answer(userID: String)
    case questions
    
    var reference: DocumentReference {
        switch self {
        case .answer(let userID):
            return Firestore.firestore()
                .collection("users")
                .document(userID)
                .collection("answers")
                .document("answer")
        case .questions:
            return Firestore.firestore()
                .collection("questions")
                .document("questions")
        }
    }
}

struct AnswerDTO: Codable {
    var answer: [Int: String]
    
    func toDomain() -> Answer {
        var answerArray = Array(repeating: "", count: answer.keys.max() ?? 0)
        answer.forEach { answerArray[$0.key] = $0.value }
        return Answer(answer: answerArray)
    }
}

struct Answer {
    var answer: [String]
}

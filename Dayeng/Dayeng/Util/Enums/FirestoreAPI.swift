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
    
    var reference: DocumentReference {
        switch self {
        case .answer(let userID):
            return Firestore.firestore()
                .collection("users")
                .document(userID)
                .collection("answers")
                .document("answer")
        }
    }
}

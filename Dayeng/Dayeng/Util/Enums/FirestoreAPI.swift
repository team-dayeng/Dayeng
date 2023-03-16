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
    case user(userID: String)
    case answer(userID: String, index: Int? = nil)
    case currentIndex(userID: String)
    
    var documentReference: DocumentReference? {
        switch self {
        case .user(let userID):
            return Firestore.firestore()
                .collection("users")
                .document(userID)
        case .answer(let userID, let index):
            guard let index else { return nil }
            return Firestore.firestore()
                .collection("users")
                .document(userID)
                .collection("answers")
                .document(String(index))
        case .currentIndex(let userID):
            return Firestore.firestore()
                .collection("users")
                .document(userID)
        }
    }
    
    var collectionReference: CollectionReference? {
        switch self {
        case .answer(let userID, _):
            return Firestore.firestore()
                .collection("users")
                .document(userID)
                .collection("answers")
        default:
            return nil
        }
    }
    
}

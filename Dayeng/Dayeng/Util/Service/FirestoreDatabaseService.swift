//
//  FirestoreDatabaseService.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/03.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import RxSwift

protocol FirestoreDatabaseService {
    func fetch<T: Decodable>(collection: String, document: String) -> Observable<T>
    func upload<T: Encodable>(collection: String, document: String, dto: T) -> Observable<Void>
    func update<T: Encodable>(collection: String, document: String, dto: T) -> Observable<Void>
    func fetch<T: Decodable>(api: FirestoreAPI) -> Observable<[T]>
    func upload<T: Encodable>(api: FirestoreAPI, dto: T) -> Observable<Void>
    func fetch<T: Decodable>(collection: String) -> Observable<[T]>
    func fetch<T: Decodable>(path: String) -> Observable<T>
    func exist(collection: String, document: String) -> Observable<String>
}

//
//  FirestoreDatabaseService.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/03.
//

import Foundation
import RxSwift

protocol FirestoreDatabaseService {
    func fetch<T: Decodable>(collection: String, document: String) -> Observable<T>
    func upload<T: Encodable>(collection: String, document: String, dto: T) -> Observable<Void>
    func update<T: Encodable>(collection: String, document: String, dto: T) -> Observable<Void>
    func fetch<T: Decodable>(api: FirestoreAPI) -> Observable<[T]>
    func upload<T: Encodable>(api: FirestoreAPI, dto: T) -> Observable<Void>
    func fetch<T: Decodable>(collection: String) -> Observable<[T]>
}

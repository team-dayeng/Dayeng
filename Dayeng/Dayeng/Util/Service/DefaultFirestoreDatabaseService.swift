//
//  DefaultFirestoreDatabaseService.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/03.
//

import RxSwift
import FirebaseFirestore
import FirebaseFirestoreSwift

final class DefaultFirestoreDatabaseService: FirestoreDatabaseService {
    private let firestore = Firestore.firestore()
    
    enum FirestoreError: Error {
        case snapshotNotFoundError
        case dataNotFoundError
        case decodeError
        case firestoreReferenceError
        case documentPathEmptyError
    }
    
    func fetch<T: Decodable>(collection: String, document: String) -> Observable<T> {
        return Observable.create { observer in
            self.firestore.collection(collection).document(document)
                .getDocument { snapshot, error in
                    if let error = error {
                        observer.onError(error)
                        return
                    }
                    
                    guard let snapshot = snapshot else {
                        observer.onError(FirestoreError.snapshotNotFoundError)
                        return
                    }
                
                    guard let data = snapshot.data() else {
                        observer.onError(FirestoreError.dataNotFoundError)
                        return
                    }
                    
                    do {
                        let dto = try Firestore.Decoder().decode(T.self, from: data)
                        observer.onNext(dto)
                    } catch {
                        observer.onError(error)
                    }
                }
            
            return Disposables.create()
        }
    }
    
    func upload<T: Encodable>(collection: String, document: String, dto: T) -> Observable<Void> {
        return Observable.create { observer in
            do {
                let data = try Firestore.Encoder().encode(dto)
                self.firestore.collection(collection).document(document)
                    .setData(data, merge: true) { error in
                        if let error = error {
                            observer.onError(error)
                            return
                        }
                        observer.onNext(())
                    }
            } catch {
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
    
    func update<T: Encodable>(collection: String, document: String, dto: T) -> Observable<Void> {
        return Observable.create { observer in
            do {
                let data = try Firestore.Encoder().encode(dto)
                self.firestore.collection(collection).document(document)
                    .updateData(data) { error in
                        if let error = error {
                            observer.onError(error)
                            return
                        }
                        observer.onNext(())
                    }
            } catch {
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
    
    /// 컬렉션 세분화 방법
    func fetch<T: Decodable>(api: FirestoreAPI) -> Observable<[T]> {
        return Observable.create { observer in
            
            guard let reference = api.collectionReference else {
                observer.onError(FirestoreError.firestoreReferenceError)
                return Disposables.create()
            }
            
            reference.getDocuments { snapshot, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                
                guard let snapshot = snapshot else {
                    observer.onError(FirestoreError.snapshotNotFoundError)
                    return
                }

                let dtos = snapshot.documents.compactMap {
                    if let data = try? $0.data(as: T.self) { return data }
                    observer.onError(FirestoreError.decodeError)
                    return nil
                }
                observer.onNext(dtos)
            }
            
            return Disposables.create()
        }
    }
    
    func upload<T: Encodable>(api: FirestoreAPI, dto: T) -> Observable<Void> {
        return Observable.create { observer in
            do {
                guard let reference = api.documentReference else {
                    observer.onError(FirestoreError.firestoreReferenceError)
                    return Disposables.create()
                }
                
                let data = try Firestore.Encoder().encode(dto)
                reference.setData(data, merge: true) { error in
                    if let error = error {
                        observer.onError(error)
                        return
                    }
                    observer.onNext(())
                }
            } catch {
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }

    /// collection 내 모든 document를 조회
    func fetch<T: Decodable>(collection: String) -> Observable<[T]> {
        return Observable.create { observer in
            self.firestore.collection(collection)
                .getDocuments { snapshot, error in
                    if let error = error {
                        observer.onError(error)
                        return
                    }
                    
                    guard let snapshot = snapshot else {
                        observer.onError(FirestoreError.snapshotNotFoundError)
                        return
                    }
                    
                    let dtos = snapshot.documents.compactMap {
                        if let data = try? $0.data(as: T.self) { return data }
                        observer.onError(FirestoreError.decodeError)
                        return nil
                    }
                    observer.onNext(dtos)
                }
            
            return Disposables.create()
        }
    }
    
    func fetch<T: Decodable>(path: String) -> Observable<T> {
        return Observable.create { observer in
            self.firestore.document(path)
                .getDocument { snapshot, error in
                    if let error = error {
                        observer.onError(error)
                        return
                    }
                    
                    guard let snapshot = snapshot else {
                        observer.onError(FirestoreError.snapshotNotFoundError)
                        return
                    }
                
                    guard let data = snapshot.data() else {
                        observer.onError(FirestoreError.dataNotFoundError)
                        return
                    }
                    
                    do {
                        let dto = try Firestore.Decoder().decode(T.self, from: data)
                        observer.onNext(dto)
                    } catch {
                        observer.onError(error)
                    }
                }
            
            return Disposables.create()
        }
    }
    
    func fetchPath(collection: String, document: String) -> Observable<String> {
        Observable.create { observer in
            if document.isEmpty {
                observer.onError(FirestoreError.documentPathEmptyError)
            } else {
                let documentReference = self.firestore.collection(collection).document(document)
                documentReference.getDocument { snapshot, _ in
                        guard let snapshot else { return }
                        
                        if snapshot.exists {
                            observer.onNext(documentReference.path)
                        } else {
                            observer.onError(FirestoreError.firestoreReferenceError)
                        }
                    }
            }
            return Disposables.create()
        }
    }
}

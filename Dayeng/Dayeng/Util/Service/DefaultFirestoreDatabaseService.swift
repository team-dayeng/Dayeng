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
    func fetch<T: Decodable>(api: FirestoreAPI) -> Observable<T> {
        return Observable.create { observer in
            api.reference.getDocument { snapshot, error in
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
    
    func upload<T: Encodable>(api: FirestoreAPI, dto: T) -> Observable<Void> {
        return Observable.create { observer in
            do {
                let data = try Firestore.Encoder().encode(dto)
                api.reference
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
    
}

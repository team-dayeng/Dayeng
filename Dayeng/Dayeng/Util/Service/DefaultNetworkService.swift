//
//  DefaultNetworkService.swift
//  Dayeng
//
//  Created by 조승기 on 2023/03/11.
//

import Foundation
import RxSwift

final class DefaultNetworkService: NetworkService {
    enum NetworkError: Error {
        case HTTPResponseError
        case invalidStatusCode(code: Int)
    }
    
    func request(
        url: URL,
        method: HTTPMethod,
        parameters: [String: Any]?,
        headers: [String: String]?
    ) -> Observable<Data?> {
        Observable.create { observer in
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            
            if let parameters = parameters {
                request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
            }
            
            if let headers = headers {
                headers.forEach {
                    request.addValue($0.value, forHTTPHeaderField: $0.key)
                }
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard error != nil else {
                    observer.onError(error!)
                    return
                }
                
                guard let response = response as? HTTPURLResponse else {
                    observer.onError(NetworkError.HTTPResponseError)
                    return
                }
                
                guard response.statusCode == 200 else {
                    observer.onError(NetworkError.invalidStatusCode(code: response.statusCode))
                    return
                }
                
                observer.onNext(data)
                observer.onCompleted()
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}

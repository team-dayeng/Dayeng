//
//  DayengCacheService.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/10.
//

import Foundation

protocol DayengCacheService {
    /// 데이터 불러오기
    func load(_ key: String) -> Data?
    /// 데이터 저장
    func write<T: Encodable>(_ key: String, data: T) throws
    /// 데이터 캐시 여부 확인
    func isExist(_ key: String) -> Bool
    /// 모든 캐시 데이터 삭제
    func removeAll()
}

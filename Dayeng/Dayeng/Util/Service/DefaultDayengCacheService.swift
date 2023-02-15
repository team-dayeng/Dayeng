//
//  DayengCacheService.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/06.
//

import Foundation

final class DefaultDayengCacheService: DayengCacheService {
    
    enum CacheError: Error {
        case encodeError
    }
    
    static let shared = DefaultDayengCacheService(name: "cache")
    
    private let memoryCache: MemoryCache
    private let diskCache: DiskCache
    
    init(name: String) {
        memoryCache = MemoryCache(name: name)
        diskCache = DiskCache(name: name)
    }
    
    func load(_ key: String) -> Data? {
        if let data = memoryCache.load(key) {
            return data
        } else if let data = diskCache.load(key) {
            memoryCache.write(key, data: data)
            return data
        }
        return nil
    }
    
    func write<T: Encodable>(_ key: String, data: T?) {
        guard let data,
              let encodedData = try? JSONEncoder().encode(data) else {
            return
        }
        memoryCache.write(key, data: encodedData)
        diskCache.write(key, data: encodedData)
    }
    
    func isExist(_ key: String) -> Bool {
        memoryCache.isExist(key) || diskCache.isExist(key)
    }
    
    func removeAll() {
        memoryCache.removeAll()
        diskCache.removeAll()
    }
}

final class MemoryCache {
    
    static let shared = MemoryCache(name: "cache")
    
    private let cache = NSCache<NSString, AnyObject>()
    
    init(name: String) {
        cache.name = name
    }
    
    func load(_ key: String) -> Data? {
        cache.object(forKey: key as NSString) as? Data
    }
    
    func write(_ key: String, data: Data?) {
        cache.setObject(data as AnyObject, forKey: key as NSString)
    }
    
    func isExist(_ key: String) -> Bool {
        cache.object(forKey: key as NSString) != nil
    }
    
    func removeAll() {
        self.cache.removeAllObjects()
    }
    
}

final class DiskCache {
    
    static let shared = DiskCache(name: "cache")
    
    private var folderURL: URL? {
        FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first?.appendingPathComponent(self.name)
    }
    
    var name: String = "cache"
    
    init(name: String) {
        self.name = name
        createFolder()
    }
    
    private func createFolder() {
        guard let folderURL else { return }
        if FileManager.default.fileExists(atPath: folderURL.path) { return }
        try? FileManager.default.createDirectory(
            at: folderURL,
            withIntermediateDirectories: true
        )
    }
    
    func load(_ key: String) -> Data? {
        guard let fileURL = URL(string: key),
              let loadURL = folderURL?.appendingPathComponent(fileURL.lastPathComponent),
              let data = FileManager.default.contents(atPath: loadURL.path) else {
            return nil
        }
        return data
    }
    
    func write(_ key: String, data: Data?) {
        guard let fileURL = URL(string: key),
              let writeURL = folderURL?.appendingPathComponent(fileURL.lastPathComponent),
              let data else {
            return
        }
        
        let attributes: [FileAttributeKey: Any] = [.modificationDate: Date()]
        FileManager.default.createFile(
            atPath: writeURL.path,
            contents: data,
            attributes: attributes
        )
    }
    
    func isExist(_ key: String) -> Bool {
        guard let fileURL = URL(string: key),
              let findURL = folderURL?.appendingPathComponent(fileURL.lastPathComponent) else {
            return false
        }
        return FileManager.default.fileExists(atPath: findURL.path)
    }
    
    func removeAll() {
        if let folderURL {
            try? FileManager.default.removeItem(at: folderURL)
        }
        self.createFolder()
    }
}

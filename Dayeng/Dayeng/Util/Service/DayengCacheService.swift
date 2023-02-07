//
//  DayengCacheService.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/06.
//

import Foundation

final class DayengCacheService {
    
    static let shared = DayengCacheService(name: "cache")
    
    private let memoryCache: MemoryCache
    private let diskCache: DiskCache
    
    init(name: String) {
        memoryCache = MemoryCache(name: name)
        diskCache = DiskCache(name: name)
    }
    
    func load(_ key: String) -> String? {
        if let data = memoryCache.load(key) {
            return data
        } else {
            return diskCache.load(key)
        }
    }
    
    func write(_ key: String, text: String) {
        memoryCache.write(key, text: text)
        diskCache.write(key, text: text)
    }
    
}

final class MemoryCache {
    
    static let shared = MemoryCache(name: "cache")
    
    private let cache = NSCache<NSString, NSString>()
    
    init(name: String) {
        cache.name = name
    }
    
    func load(_ key: String) -> String? {
        return cache.object(forKey: key as NSString) as? String
    }
    
    func write(_ key: String, text: String) {
        cache.setObject(NSString(string: text), forKey: key as NSString)
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
    
    func load(_ key: String) -> String? {
        guard let fileURL = URL(string: key),
              let loadURL = folderURL?.appendingPathComponent(fileURL.lastPathComponent),
              let data = FileManager.default.contents(atPath: loadURL.path) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    func write(_ key: String, text: String?) {
        guard let fileURL = URL(string: key),
              let writeURL = folderURL?.appendingPathComponent(fileURL.lastPathComponent) else {
            return
        }
        
        let attributes: [FileAttributeKey: Any] = [.modificationDate: Date()]
        FileManager.default.createFile(
            atPath: writeURL.path,
            contents: text?.data(using: .utf8),
            attributes: attributes
        )
    }
}

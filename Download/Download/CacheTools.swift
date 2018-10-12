//
//  CacheTools.swift
//  SwiftTool
//
//  Created by 张书孟 on 2018/9/5.
//  Copyright © 2018年 ZSM. All rights reserved.
//

import Cache

class CacheTools<T: Codable> {
    
    var storage: Storage<T>?
    
    init() {
        let diskConfig = DiskConfig(name: DownloadCacheModelPath)
        let memoryConfig = MemoryConfig(expiry: .never)
        do {
            storage = try Storage(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forCodable(ofType: T.self))
        } catch {
//            debugPrint("CacheTools init storage error: \(error)")
        }
    }
    
    func setObject(object: T, forKey: String) {
        do {
            try storage?.setObject(object, forKey: forKey)
        } catch {
//            debugPrint("CacheTools save obiect error: \(error)")
        }
    }
    
    func object(forKey key: String) -> T? {
        do {
            return try storage?.object(forKey: key) ?? nil
        } catch {
//            debugPrint("CacheTools get obiect error: \(error)")
            return nil
        }
    }
    
    func removeObiect(forKey key: String) {
        do {
            try storage?.removeObject(forKey: key)
        } catch {
//            debugPrint("CacheTools remove obiect error: \(error)")
        }
    }
    
    func removeAll() {
        do {
            try storage?.removeAll()
        } catch {
//            debugPrint("CacheTools remove all obiect error: \(error)")
        }
    }
}

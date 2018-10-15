
//
//  Download+Extension.swift
//  Download
//
//  Created by 张书孟 on 2018/10/9.
//  Copyright © 2018年 zsm. All rights reserved.
//

import Foundation
import Cache

public extension String {
    var dw_MD5String: String {
        return MD5(self)
    }
}

public extension String {
    
    var dw_getFileName: String {
        return self.dw_MD5String + self.dw_pathExtension
    }
    
    /// 从url中获取后缀
    var dw_pathExtension: String {
        if let url = URL(string: self) {
            return url.pathExtension.isEmpty ? "" : ".\(url.pathExtension)"
        }
        return ""
    }
}

public extension String {
    var dw_isURL: Bool {
        let url = "[a-zA-z]+://[^\\s]*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", url)
        return predicate.evaluate(with: self)
    }
}

public extension String {
    
    /// 遍历所有子目录， 并计算文件大小 单位：字节
    var dw_getCacheSize: Double {
        var fileSize: Double = 0.0
        if let childFilePath = FileManager.default.subpaths(atPath: self) {
            for path in childFilePath {
                let fileAbsoluePath = self + path
                fileSize += fileAbsoluePath.dw_fileSize
            }
        }
        return fileSize
    }
    
    /// 计算单个文件的大小 单位：字节
    var dw_fileSize: Double {
        let manager = FileManager.default
        var fileSize: Double = 0.0
        if manager.fileExists(atPath: self) {
            do {
                let attributes = try manager.attributesOfItem(atPath: self)
                if !attributes.isEmpty, let size = attributes[FileAttributeKey.size] as? Double {
                    fileSize = size
                }
            } catch {}
        }
        return fileSize
    }
}


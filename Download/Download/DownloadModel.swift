//
//  DownloadModel.swift
//  Download
//
//  Created by 张书孟 on 2018/10/9.
//  Copyright © 2018年 zsm. All rights reserved.
//

import UIKit

let DownloadStateChangeNotification: Notification.Name = Notification.Name("DownloadStateChangeNotification")
let DownloadProgressNotification: Notification.Name = Notification.Name("DownloadProgressNotification")

class DownloadModel: NSObject {

    var stream: OutputStream? /// 流
    
    var states: DownloadState = .default {
        didSet {
            state(states)
            NotificationCenter.default.post(name: DownloadStateChangeNotification, object: self)
        }
    }
    
    var state: (DownloadState) -> Void = { _ in } /// 下载状态
    var download: (Double, Int, Int) -> Void = { _, _, _ in}
    
    var model: DownloadDescModel = DownloadDescModel()
    
    func getDownloadModel(url: String) -> DownloadDescModel? {
        return CacheTools<DownloadDescModel>().object(forKey: url)
    }
    
    func save(url: String) {
        CacheTools<DownloadDescModel>().setObject(object: model, forKey: url)
    }
    
    func delete(url: String) {
        CacheTools<DownloadDescModel>().removeObiect(forKey: url)
    }
}

class DownloadDescModel: Codable {
    var url: String? /// 下载地址
    
    var totalLength: Int = 0 /// 获得服务器这次请求 返回数据的总长度
    var receivedSize: Int = 0 /// 已经下载的长度
    
    /// 下载进度
    var progress: Double = 0.0 {
        didSet {
            NotificationCenter.default.post(name: DownloadProgressNotification, object: self)
        }
    }
    
    var name: String?
}


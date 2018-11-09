//
//  DownloadModel.swift
//  Download
//
//  Created by 张书孟 on 2018/10/9.
//  Copyright © 2018年 zsm. All rights reserved.
//

import UIKit

/// 进度通知
let DownloadProgressNotification: Notification.Name = Notification.Name("DownloadProgressNotification")

class DownloadModel: NSObject {

    var stream: OutputStream? /// 流
    
    public var states: DownloadState = .default {
        didSet {
            model.state = states
            if let url = model.url {
                if let proModel = getDownloadModel(url: url) {
                    model.progress = proModel.progress
                }
                save(url: url, descModel: model)
            }
        }
    }
    
    public var model: DownloadDescModel = DownloadDescModel()
    
    public func getDownloadModel(url: String) -> DownloadDescModel? {
        return DownloadCache<DownloadDescModel>().object(forKey: url)
    }
    
    public func save(url: String, descModel: DownloadDescModel) {
        DownloadCache<DownloadDescModel>().setObject(object: descModel, forKey: url)
    }
    
    public func delete(url: String) {
        DownloadCache<DownloadDescModel>().removeObiect(forKey: url)
    }
}

class DownloadDescModel: Codable {
    
    /** 必须有的属性 -- 开始 */
    public var url: String? /// 下载地址
    
    public var totalLength: Int = 0 /// 获得服务器这次请求 返回数据的总长度
    public var receivedSize: Int = 0 /// 已经下载的长度
    
    /// 下载进度
    public var progress: Double = 0.0 {
        didSet {
            NotificationCenter.default.post(name: DownloadProgressNotification, object: self)
        }
    }
    
    public var state: DownloadState = .default
    /** 必须有的属性 -- 结束 */
    
    /** 可选属性 -- 开始 */
    /// 例如 下载文件的名称、描述、图片 ...
    public var name: String?
}


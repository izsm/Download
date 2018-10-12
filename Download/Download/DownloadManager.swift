//
//  DownloadManager.swift
//  Download
//
//  Created by 张书孟 on 2018/10/10.
//  Copyright © 2018年 zsm. All rights reserved.
//

import UIKit

enum DownloadState: Int, Codable {
    case `default` /// 默认
    case start /// 下载中
    case waiting /// 等待
    case suspended /// 下载暂停
    case completed /// 下载完成
    case failed /// 下载失败
}

/// 缓存主目录
let DownloadHomeDirectory = NSHomeDirectory() + "/Library/Caches/DownloadCache/"
/// 下载文件的路径
let DownloadCachePath = DownloadHomeDirectory + "DownloadCache/"
/// 保存下载的url路径(取模型用)
let DownloadCacheURLPath = DownloadHomeDirectory + "URL.plist"
/// 保存下载文件的model路径
let DownloadCacheModelPath = "DownloadCache/DownloadModelCache"

class DownloadManager: NSObject {

    static let `default` = DownloadManager()
    
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "DownloadBackgroundSessionIdentifier")
        let queue = OperationQueue()
//        queue.maxConcurrentOperationCount = 1
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: queue)
        return session
    }()
    
    private var sessionModels: [String: DownloadModel] = [String: DownloadModel]()
    
    private var tasks: [String: URLSessionDataTask] = [String: URLSessionDataTask]()
    
    private var downloadState: DownloadState = .default
    
}

extension DownloadManager {
    /// 根据url获得对应的下载任务
    private func getTask(url: String) -> URLSessionDataTask? {
        guard url.dw_isURL else { return nil }
        return tasks[url.dw_getFileName]
    }
    
    /// 获取对应的下载信息模型
    private func getSessionModel(taskIdentifier: Int) -> DownloadModel? {
        return sessionModels["\(taskIdentifier)"]
    }
    
    /// 开始下载
    private func start(url: String) {
        guard url.dw_isURL else { return }
        if let task = getTask(url: url) {
            task.resume()
            if let model = getSessionModel(taskIdentifier: task.taskIdentifier) {
//                model.state(.start)
                model.states = .start
            }
        }
    }
    
    private func handle(url: String) {
        guard url.dw_isURL else { return }
        if let task = getTask(url: url) {
            if task.state == .running {
                pause(url: url)
            } else {
                start(url: url)
            }
        }
    }
    
    /// 暂停下载
    private func pause(url: String) {
        guard url.dw_isURL else { return }
        if let task = getTask(url: url) {
            task.suspend()
            if let model = getSessionModel(taskIdentifier: task.taskIdentifier) {
//                model.state(.suspended)
                model.states = .suspended
            }
        }
    }
    
    /// 暂停所有任务
    private func suspendAllTasks() {
        for (_, task) in tasks.values.enumerated() {
            task.suspend()
        }
        
        for (_, sessionModel) in sessionModels.values.enumerated() {
//            sessionModel.state(.suspended)
            sessionModel.states = .suspended
        }
    }
    
    /// 创建缓存路径
    private func path(url: String) -> String {
        guard url.dw_isURL else { return DownloadCachePath }
        do {
            try FileManager.default.createDirectory(atPath: DownloadCachePath, withIntermediateDirectories: true, attributes: nil)
            return DownloadCachePath + url.dw_getFileName
        } catch {
            return DownloadCachePath
        }
    }
    
    /// 保存下载的url(取 model 用)
    private func save(url: String) {
        guard url.dw_isURL else { return }
        let urlArr: NSMutableArray = NSMutableArray(contentsOfFile: DownloadCacheURLPath) ?? NSMutableArray()
        guard !(urlArr.contains(url)) else { return }
        urlArr.add(url)
        urlArr.write(toFile: DownloadCacheURLPath, atomically: true)
    }
    
    /// 获取已下载文件的大小
    private func getDownloadSize(url: String) -> Int {
        guard url.dw_isURL else { return 0 }
        do {
            if let size = try FileManager.default.attributesOfItem(atPath: path(url: url))[FileAttributeKey.size] as? Int {
                return size
            } else {
                return 0
            }
        } catch {
            return 0
        }
    }
}

// MARK: public
extension DownloadManager {
    
    public func download(model: DownloadModel,
                         progress: @escaping (Double, Int, Int) -> Void,
                         state: @escaping (DownloadState) -> Void) {
        
        guard let url = model.model.url, url.dw_isURL else { return }
        
        guard !isCompletion(url: url) else {
            state(.completed)
            return
        }
        
        if let _ = tasks[url.dw_getFileName] {
            handle(url: url)
            return
        }
        
        // 创建流
        let stream = OutputStream(toFileAtPath: path(url: url), append: true)
        // 创建请求
        var request = URLRequest(url: URL(string: url)!)
        // 忽略本地缓存，代理服务器以及其他中介，直接请求源服务端
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        // 设置请求头
        request.setValue("bytes=\(getDownloadSize(url: url))-", forHTTPHeaderField: "Range")
        // 创建一个Data任务
        let task = session.dataTask(with: request)
        let taskIdentifier = arc4random() % ((arc4random() % 10000 + arc4random() % 10000))
        task.setValue(taskIdentifier, forKey: "taskIdentifier")
        // 保存任务
        tasks[url.dw_getFileName] = task
        
        model.stream = stream
        model.download = progress
        model.state = state
        sessionModels["\(taskIdentifier)"] = model
        
        start(url: url)
    }
    
    /// 判断该文件是否下载完成
    func isCompletion(url: String) -> Bool {
        guard url.dw_isURL else { return false }
        if let model = DownloadModel().getDownloadModel(url: url),
            let totalLength = model.totalLength, totalLength == getDownloadSize(url: url) {
            return true
        }
        return false
    }
    
    /// 判断该文件是否存在
    func isExistence(url: String) -> Bool {
        if let _ = DownloadModel().getDownloadModel(url: url) {
            return true
        }
        return false
    }
    
    /// 取消任务
    func cancelTask(url: String) {
        guard url.dw_isURL else { return }
        if let task = getTask(url: url) {
            task.suspend()
            task.cancel()
            if let model = getSessionModel(taskIdentifier: task.taskIdentifier) {
//                model.state(.failed)
                model.states = .failed
                model.stream?.close()
                sessionModels.removeValue(forKey: "\(task.taskIdentifier)")
                tasks.removeValue(forKey: url.dw_getFileName)
            }
        }
    }
    
    /// 取消所有任务
    func cancelAllTask() {
        for (_, task) in tasks.values.enumerated() {
            task.suspend()
            task.cancel()
        }
        tasks.removeAll()
        for (_, sessionModel) in sessionModels.values.enumerated() {
            sessionModel.stream?.close()
//            sessionModel.state(.failed)
            sessionModel.states = .failed
        }
        sessionModels.removeAll()
    }
    
    /// 根据url删除资源
    func deleteFile(url: String) {
        guard url.dw_isURL else { return }
        cancelTask(url: url)
        DownloadModel().delete(url: url)
        do {
            try FileManager.default.removeItem(atPath: DownloadCachePath + url.dw_getFileName)
        } catch {}
        
        let urlArr: NSMutableArray = NSMutableArray(contentsOfFile: DownloadCacheURLPath) ?? NSMutableArray()
        guard (urlArr.contains(url)) else { return }
        urlArr.remove(url)
        urlArr.write(toFile: DownloadCacheURLPath, atomically: true)
    }
    
    /// 清空所有下载资源
    func deleteAllFile() {
        // 取消所有任务
        cancelAllTask()
        
        do {
            try FileManager.default.removeItem(atPath: DownloadHomeDirectory)
        } catch {}
    }
    
    /// 获取已下载的数据
    func getDownloadModels() -> [DownloadModel] {
        let urls: NSMutableArray = NSMutableArray(contentsOfFile: DownloadCacheURLPath) ?? NSMutableArray()
        var models = [DownloadModel]()
        for url in urls {
            if let url2 = url as? String {
                let downloadModel = DownloadModel()
                if let model = downloadModel.getDownloadModel(url: url2) {
                    downloadModel.model = model
                    models.append(downloadModel)
                }
            }
        }
        return models
    }
    
    /// 获取总缓存大小 单位：字节
    func getCacheSize() -> Double {
        return DownloadHomeDirectory.dw_getCacheSize
    }
}

extension DownloadManager: URLSessionDelegate {
    /// 应用处于后台，所有下载任务完成及URLSession协议调用之后调用
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {}
}

extension DownloadManager: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if let error = error, error.localizedDescription == "cancelled" { return }
        
        guard let model = sessionModels["\(task.taskIdentifier)"],
            let url = model.model.url,
            url.dw_isURL else { return }
        
        if let _ = error {
            debugPrint("下载失败")
//            model.state(.failed)
            model.states = .failed
        } else {
            debugPrint("下载完成")
//            model.state(.completed)
            model.states = .completed
        }
        
        // 关闭流
        model.stream?.close()
        model.stream = nil
        // 清除任务
        tasks.removeValue(forKey: url.dw_getFileName)
        sessionModels.removeValue(forKey: "\(task.taskIdentifier)")
    }
}

extension DownloadManager: URLSessionDataDelegate {
    /// 接收到响应
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        guard let model = sessionModels["\(dataTask.taskIdentifier)"],
            let stream = model.stream,
            let url = model.model.url else { return }
        
        // 打开流
        stream.open()
        
        // 获得服务器这次请求 返回数据的总长度
        model.model.totalLength = Int(response.expectedContentLength) + getDownloadSize(url: url)
        
        model.save(url: url)
        save(url: url)
        
        // 接收这个请求，允许接收服务器的数据
        completionHandler(.allow)
    }
    
    /// 接收到服务器返回的数据
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let model = sessionModels["\(dataTask.taskIdentifier)"],
            let stream = model.stream,
            let url = model.model.url else { return }
        let bytes = [UInt8](data)
        // 写入数据
        stream.write(UnsafePointer<UInt8>(bytes), maxLength: data.count)
        // 下载进度
        let receivedSize = getDownloadSize(url: url)
        let expectedSize = model.model.totalLength ?? 0
        let progress: Double = Double(receivedSize) / Double(expectedSize)
        
        model.download(progress, receivedSize, expectedSize)
        model.model.progress = progress
        model.save(url: url)
    }
}

# Download
### 文件下载，支持断点续传、后台下载、设置下载并发数
### 演示：
![Download.gif](https://upload-images.jianshu.io/upload_images/3203108-e64c251d147ef9cb.gif?imageMogr2/auto-orient/strip)
###API:
```
/// 设置下载并发数， 默认3
DownloadManager.default.maxDownloadCount = 3
/// 开启下载
public func download(model: DownloadModel)
/// 判断该文件是否下载完成
public func isCompletion(url: String) -> Bool
/// 判断该文件是否存在
public func isExistence(url: String) -> Bool
/// 根据url取消/暂停任务
public func cancelTask(url: String)
/// 取消/暂停所有任务
public func cancelAllTask()
/// 根据url删除资源
public func deleteFile(url: String)
/// 清空所有下载资源
public func deleteAllFile()
/// 获取下载的数据
public func getDownloadModels() -> [DownloadModel]
/// 获取下载完成的数据
public func getDownloadFinishModels() -> [DownloadModel]
/// 获取未下载完成的数据
public func getDownloadingModel() -> [DownloadModel]
/// 将未完成的下载状态改为.suspended
public func updateDownloadingStateWithSuspended()
/// 开启未完成的下载
public func updateDownloading()
/// 获取总缓存大小 单位：字节
public func getCacheSize() -> Double
```



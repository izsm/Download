//
//  ViewController.swift
//  Download
//
//  Created by 张书孟 on 2018/10/9.
//  Copyright © 2018年 zsm. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 64, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 64), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        tableView.register(ViewTableViewCell.self, forCellReuseIdentifier: "ViewTableViewCell")
        return tableView
    }()
    
    private var dataSource: [DownloadModel] = [DownloadModel]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource.removeAll()
        loadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        DownloadManager.default.cancelAllTask()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DownloadManager.default.maxDownloadCount = 1
        
        addNotification()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancelClick))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "下载管理", style: .plain, target: self, action: #selector(nextClick))
        
        debugPrint(DownloadManager.default.getCacheSize())
        
        debugPrint(NSHomeDirectory())
        
        view.addSubview(tableView)
        
        loadData()
    }
    
    private func loadData() {
        let model1 = DownloadModel()
        model1.model.name = "测试1"
        model1.model.url = "http://tya.znzkj.net/touyanshe_web/outImages/20180104/20180104_5642247.pdf"
        
        let model2 = DownloadModel()
        model2.model.name = "测试2"
        model2.model.url = "http://7xqhmn.media1.z0.glb.clouddn.com/femorning-20161106.mp4"
        
        let model3 = DownloadModel()
        model3.model.name = "测试3"
        model3.model.url = "http://file.ubye.cn/UbyeServiceFiles/video/143/YCJS2018082321125/201808231807433820180823180734.mp4"
        
        let model4 = DownloadModel()
        model4.model.name = "测试4"
        model4.model.url = "http://www.hangge.com/blog_uploads/201709/2017091219324377713.zip"
        
        let model5 = DownloadModel()
        model5.model.name = "测试5"
        model5.model.url = "http://www.runoob.com/try/demo_source/movie.mp4"
        
        let model6 = DownloadModel()
        model6.model.name = "测试6"
        model6.model.url = "https://download.jetbrains.8686c.com/python/pycharm-professional-2017.3.2.dmg"
        
        let model7 = DownloadModel()
        model7.model.name = "测试7"
        model7.model.url = "https://download.sketchapp.com/sketch-51.1-57501.zip"
        
        let model8 = DownloadModel()
        model8.model.name = "测试8"
        model8.model.url = "http://static.realm.io/downloads/swift/realm-swift-3.4.0.zip"
        
        let model9 = DownloadModel()
        model9.model.name = "测试9"
        model9.model.url = "http://qunying.jb51.net:81/201710/books/iOS11Swift4_jb51.rar"
        
//        let model10 = DownloadModel()
//        model10.model.name = "测试10"
//        model10.model.url = "http://www.hangge.com/blog_uploads/201709/2017091219324377713.zip"
        
        dataSource.append(model1)
        dataSource.append(model2)
        dataSource.append(model3)
        dataSource.append(model4)
        dataSource.append(model5)
        dataSource.append(model6)
        dataSource.append(model7)
        dataSource.append(model8)
        dataSource.append(model9)
//        dataSource.append(model10)
        tableView.reloadData()
    }
    
    private func addNotification() {
        // 进度通知
        NotificationCenter.default.addObserver(self, selector: #selector(downLoadProgress(notification:)), name: Notification.Name("DownloadProgressNotification"), object: nil)
        // 状态改变通知
        NotificationCenter.default.addObserver(self, selector: #selector(downLoadStateChange(notification:)), name: Notification.Name("DownloadStateChangeNotification"), object: nil)
    }
    
    @objc private func nextClick() {
        navigationController?.pushViewController(DownloadViewController(), animated: true)
    }
    
    @objc private func cancelClick() {
        DownloadManager.default.cancelAllTask()
    }
    
    @objc private func downLoadProgress(notification: Notification) {
        if let model = notification.object as? DownloadDescModel {
            for (index, descModel) in dataSource.enumerated() {
                if model.url == descModel.model.url {
                    DispatchQueue.main.async { [weak self] in
                        guard let `self` = self else { return }
                        if let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ViewTableViewCell {
                            cell.updateView(model: model)
                        }
                    }
                }
            }
        }
    }
    
    @objc private func downLoadStateChange(notification: Notification) {
        if let model = notification.object as? DownloadModel {
            for (index, downloadModel) in dataSource.enumerated() {
                if model.model.url == downloadModel.model.url {
                    dataSource[index] = downloadModel
                    DispatchQueue.main.async { [weak self] in
                        guard let `self` = self else { return }
                        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    }
                }
            }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ViewTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ViewTableViewCell") as! ViewTableViewCell
        let model = dataSource[indexPath.row]
        cell.update(model: model)
        return cell
    }
}

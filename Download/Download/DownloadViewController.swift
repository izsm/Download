//
//  DownloadViewController.swift
//  Download
//
//  Created by 张书孟 on 2018/10/10.
//  Copyright © 2018年 zsm. All rights reserved.
//

import UIKit
import MJRefresh

class DownloadViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 64, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 64), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        tableView.register(ViewTableViewCell.self, forCellReuseIdentifier: "ViewTableViewCell")
        return tableView
    }()
    
    private var dataSource: [DownloadModel] = [DownloadModel]()
    
    private var page: Int = 0
    
    deinit {
        debugPrint("deinit - DownloadViewController")
//        DownloadManager.default.cancelAllTask()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNotification()
        addSubviews()
        loadData()
    }
    
    private func addNotification() {
        // 进度通知
        NotificationCenter.default.addObserver(self, selector: #selector(downLoadProgress(notification:)), name: DownloadProgressNotification, object: nil)
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
}

extension DownloadViewController {
    
    private func addSubviews() {
        
        let startBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        startBtn.setTitle("全部开始", for: .normal)
        startBtn.setTitle("全部暂停", for: .selected)
        startBtn.setTitleColor(UIColor.black, for: .normal)
        startBtn.addTarget(self, action: #selector(cancelClick(sender:)), for: .touchUpInside)
        let startItem = UIBarButtonItem(customView: startBtn)
        
        let deleteItem = UIBarButtonItem(title: "删除", style: .plain, target: self, action: #selector(deleteClick))
        
        navigationItem.rightBarButtonItems = [startItem, deleteItem]
        
        view.addSubview(tableView)
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            guard let `self` = self else { return }
            self.page = 1
            self.loadData()
        })
    }
    
    private func loadData() {
        NotificationCenter.default.removeObserver(self)
        if page == 0 {
            if let model = DownloadManager.default.getDownloadModels().first {
                dataSource = [model]
            }
        } else {
            dataSource = DownloadManager.default.getDownloadModels()
        }
        
        tableView.reloadData()
        tableView.mj_header.endRefreshing()
        addNotification()
    }
    
    @objc private func deleteClick() {
        NotificationCenter.default.removeObserver(self)
        DownloadManager.default.deleteAllFile()
        loadData()
        addNotification()
    }
    
    @objc private func cancelClick(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.isSelected ? DownloadManager.default.updateDownloading() : DownloadManager.default.cancelAllTask()
    }
}

extension DownloadViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ViewTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ViewTableViewCell") as! ViewTableViewCell
        cell.update(model: dataSource[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let model = dataSource[indexPath.row]
        let deleteRowAction: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "删除") { [weak self] (action, index) in
            guard let `self` = self else { return }
            /// 删除时先移除通知再注册通知（防止数据改变导致进度和状态错乱）
            NotificationCenter.default.removeObserver(self)
            DownloadManager.default.deleteFile(url: model.model.url!)
            self.loadData()
            self.addNotification()
        }
        
        deleteRowAction.backgroundColor = UIColor.red
        
        return [deleteRowAction]
    }
}


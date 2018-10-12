//
//  DownloadViewController.swift
//  Download
//
//  Created by 张书孟 on 2018/10/10.
//  Copyright © 2018年 zsm. All rights reserved.
//

import UIKit

class DownloadViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 64, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 64), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        tableView.register(DownloadTableViewCell.self, forCellReuseIdentifier: "DownloadTableViewCell")
        return tableView
    }()
    
    private var dataSource: [DownloadModel] = [DownloadModel]()
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(downLoadProgress(notification:)), name: Notification.Name("DownloadProgressNotification"), object: nil)
        // 状态改变通知
        NotificationCenter.default.addObserver(self, selector: #selector(downLoadStateChange(notification:)), name: Notification.Name("DownloadStateChangeNotification"), object: nil)
    }
    
    @objc private func downLoadProgress(notification: Notification) {
        if let model = notification.object as? DownloadDescModel {
            for (index, descModel) in dataSource.enumerated() {
                if model.url == descModel.model.url {
                    DispatchQueue.main.async { [weak self] in
                        guard let `self` = self else { return }
                        if let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? DownloadTableViewCell {
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

extension DownloadViewController {
    
    private func addSubviews() {
        view.addSubview(tableView)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "删除", style: .plain, target: self, action: #selector(cancelClick))
    }
    
    private func loadData() {
        dataSource = DownloadManager.default.getDownloadModels()
        tableView.reloadData()
    }
    
    @objc private func cancelClick() {
        NotificationCenter.default.removeObserver(self)
        DownloadManager.default.deleteAllFile()
        loadData()
    }
}

extension DownloadViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DownloadTableViewCell = tableView.dequeueReusableCell(withIdentifier: "DownloadTableViewCell") as! DownloadTableViewCell
        cell.update(model: dataSource[indexPath.row])
        return cell
    }
}


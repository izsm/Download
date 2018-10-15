//
//  ViewTableViewCell.swift
//  Download
//
//  Created by 张书孟 on 2018/10/10.
//  Copyright © 2018年 zsm. All rights reserved.
//

import SnapKit

class ViewTableViewCell: UITableViewCell {

    private lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.textColor = UIColor.black
        nameLabel.backgroundColor = UIColor.orange
        return nameLabel
    }()
    
    private lazy var progressView: ProgressView = {
        ProgressView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 200, height: 40))
    }()
    
    private lazy var stateBtn: UIButton = {
        let stateBtn = UIButton()
        stateBtn.backgroundColor = UIColor.red
        stateBtn.addTarget(self, action: #selector(stateBtnClick(sender:)), for: .touchUpInside)
        return stateBtn
    }()
    
    private var model: DownloadModel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        addSubviews()
    }
    
    func update(model: DownloadModel) {
        self.model = model
        nameLabel.text = model.model.name
        
        if let url = model.model.url, let model1 = model.getDownloadModel(url: url) {
            stateBtn.setTitle(state(state: model1.state), for: .normal)
//            progressLabel.text = "\(model1.progress)"
            progressView.update(model: model1)
        } else {
            progressView.update(model: model.model)
            stateBtn.setTitle(state(state: model.states), for: .normal)
        }
    }
    
    func updateView(model: DownloadDescModel) {
        progressView.update(model: model)
        stateBtn.setTitle(state(state: model.state), for: .normal)
    }
    
    @objc private func stateBtnClick(sender: UIButton) {
        
        guard let downloadModel = model else {
            return
        }
        
        DownloadManager.default.download(model: downloadModel)
    }
    
    private func state(state: DownloadState) -> String {
        switch state {
        case .start:
            return "下载中"
        case .completed:
            return "完成"
        case .waiting:
            return "等待"
        case .suspended:
            return "暂停"
        default:
            return "开始"
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ViewTableViewCell {
    
    private func addSubviews() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(progressView)
        contentView.addSubview(stateBtn)
        
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.size.equalTo(CGSize(width: 100, height: 40))
        }
        
        progressView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(nameLabel.snp.right)
            make.width.equalTo(UIScreen.main.bounds.size.width - 200)
            make.height.equalTo(40)
        }
        
        stateBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
            make.size.equalTo(CGSize(width: 80, height: 40))
        }
    }
}

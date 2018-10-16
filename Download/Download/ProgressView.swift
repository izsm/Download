//
//  ProgressView.swift
//  Download
//
//  Created by 张书孟 on 2018/10/15.
//  Copyright © 2018年 zsm. All rights reserved.
//

import UIKit

class ProgressView: UIView {
    
    private lazy var bgView: UIView = {
        let bgView = UIView()
        bgView.backgroundColor = UIColor.gray
        return bgView
    }()
    
    private lazy var progressView: UIView = {
        let progressView = UIView()
        progressView.backgroundColor = UIColor.green
        return progressView
    }()
    
    private lazy var progressLabel: UILabel = {
        let progressLabel = UILabel()
        progressLabel.textColor = UIColor.black
        return progressLabel
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubViews()
    }
    
    func update(model: DownloadDescModel) {
        progressLabel.text = "\(model.progress)"
        debugPrint("progress: \(model.progress) -- receivedSize: \(model.receivedSize) -- totalLength: \(model.totalLength)")
        
        let width = frame.size.width * CGFloat(model.progress)
        progressView.snp.updateConstraints { (make) in
            make.width.equalTo(width)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ProgressView {
    
    private func addSubViews() {
        addSubview(bgView)
        addSubview(progressView)
        addSubview(progressLabel)
        
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        progressView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(0)
        }
        
        progressLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

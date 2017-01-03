//
//  TableViewHeader.swift
//  Nightjar2
//
//  Created by 黄穆斌 on 2016/12/3.
//  Copyright © 2016年 Myron. All rights reserved.
//

import UIKit


class TableViewRefresh: UIView, TableViewRefreshProtocol {
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initDeploy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initDeploy()
    }
    
    private func initDeploy() {
        self.clipsToBounds = true
        self.backgroundColor = Pallette.viewBack
        
        //
        addSubview(label)
        //label.textColor = UIColor(red: 50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 1)
        label.textColor = Pallette.tint
        label.text = ""
        Layouter(superview: self, view: label).centerY().centerX(19)
        
        //
        addSubview(imageView)
        imageView.image = UIImage(named: "Refresh")
        Layouter(superview: self, view: imageView).size(w: 30, h: 30).centerY().setViews(relative: label).layout(edge: .trailing, to: .leading, constant: -16)
        imageView.transform = isHeader ? CGAffineTransform(rotationAngle: CGFloat(M_PI)) : CGAffineTransform(rotationAngle: CGFloat(0))
        
        //
        addSubview(activity)
        activity.hidesWhenStopped = true
        //activity.color = UIColor(red: 50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 1)
        activity.color = Pallette.tint
        Layouter(superview: self, view: activity, relative: imageView).center()
    }
    
    // MARK: - TableViewRefreshProtocol
    
    var viewHeight: CGFloat = 80
    
    func update(status: TableViewRefreshViewStatus) {
        switch status {
        case .draging(let value):
            if value > 1 {
                label.text = dragedText
                UIView.animate(withDuration: 0.2, animations: {
                    self.imageView.transform = self.isHeader ? CGAffineTransform(rotationAngle: CGFloat(0)) : CGAffineTransform(rotationAngle: CGFloat(M_PI))
                })
            } else {
                label.text = dragingText
                UIView.animate(withDuration: 0.2, animations: {
                    self.imageView.transform = self.isHeader ? CGAffineTransform(rotationAngle: CGFloat(M_PI)) : CGAffineTransform(rotationAngle: CGFloat(0))
                })
            }
        case .willRefresh:
            break
        case .refreshing(_):
            imageView.image = nil
            label.text = loadingText
            activity.startAnimating()
        case .finished(let value, let text):
            activity.stopAnimating()
            if value {
                imageView.transform = CGAffineTransform(rotationAngle: CGFloat(0))
                label.text = text ?? loadedTrue
                imageView.image = UIImage(named: "Success")
            } else {
                imageView.transform = CGAffineTransform(rotationAngle: CGFloat(0))
                label.text = text ?? loadedFalse
                imageView.image = UIImage(named: "Error")
            }
        }
    }
    
    func reset() {
        imageView.image = UIImage(named: "Refresh")
        imageView.transform = isHeader ? CGAffineTransform(rotationAngle: CGFloat(M_PI)) : CGAffineTransform(rotationAngle: CGFloat(0))
        label.text = dragedText
        activity.stopAnimating()
    }
    
    // MARK: - Views
    
    var imageView = UIImageView()
    var label = UILabel()
    var activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    
    // MARK: - Data
    
    var isHeader: Bool = true
    
    var dragingText = "下拉刷新"
    var dragedText  = "松手刷新"
    var loadingText = "加载中"
    var loadedTrue  = "加载成功"
    var loadedFalse = "加载失败"
}

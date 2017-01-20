//
//  ImageViewerCollectionCell.swift
//  ImageViewer
//
//  Created by 黄穆斌 on 2016/12/2.
//  Copyright © 2016年 Myron. All rights reserved.
//

import UIKit

class ImageViewerCollectionCell: UICollectionViewCell {
    
    static let cellSelectImage = UIImage(named: "Select")
    
    var showSelect = false {
        didSet {
            selectView.image = showSelect ? ImageViewerCollectionCell.cellSelectImage : nil
        }
    }
    
    var imageView = UIImageView()
    var selectView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initDeploy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initDeploy()
    }
    
    func initDeploy() {
        addSubview(imageView)
        addSubview(selectView)
        
        Layouter(superview: self, view: imageView).edges()
        Layouter(superview: self, view: selectView).trailing(-10).bottom(-10).size(w: 30, h: 30)
    }
    
}

class ImageViewerCollectionHeader: UICollectionReusableView {
    
    var label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initDeploy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initDeploy()
    }
    
    func initDeploy() {
        label.textColor = UIColor.white
        
        addSubview(label)
        
        Layouter(superview: self, view: label).centerY().leading(8)
    }
    
}

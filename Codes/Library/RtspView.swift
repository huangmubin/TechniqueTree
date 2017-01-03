//
//  RtspView.swift
//  RangerCam2
//
//  Created by 黄穆斌 on 2016/12/30.
//  Copyright © 2016年 黄穆斌. All rights reserved.
//

import UIKit

class RtspView: UIView {

    var imageView = UIImageView()
    var rtspUrl = ""
    var activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    var layouts = Layouter.Container()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        deploy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        deploy()
    }
    
    private func deploy() {
        imageView.backgroundColor = UIColor.black
        addSubview(imageView)
        Layouter(superview: self, view: imageView).edges()
        
        activity.hidesWhenStopped = true
        activity.startAnimating()
        addSubview(activity)
        Layouter(superview: self, view: activity).center()
    }
    
    // MARK: - Autolayout
    
    func autolayoutToSuperView() {
        if let sview = superview {
            Layouter(superview: sview, view: self, container: layouts).centerX().width()
                .top(80).contrainer(key: "PortraitTop", orient: .portrait)
                .aspect(multiplier: 16.0/9.0).contrainer(key: "PortraitAspect", orient: .portrait)
                .centerY().contrainer(key: "LandscapeCenterY", orient: .landscape)
                .height().contrainer(key: "LandscapeHeight", orient: .landscape)
            
            layouts.updateActive()
            sview.layoutIfNeeded()
        }
    }
    
    // MARK: - Methods
    
    func play() {
        
    }
    
    func stop() {
        
    }

}

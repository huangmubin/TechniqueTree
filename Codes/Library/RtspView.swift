//
//  RtspView.swift
//  RangerCam2
//
//  Created by 黄穆斌 on 2016/12/30.
//  Copyright © 2016年 黄穆斌. All rights reserved.
//

import UIKit

class RtspView: UIView, FFMpegPlayerDelegate {

    var imageView = UIImageView()
    var rtspUrl = ""
    var activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    var layouts = Layouter.Container()
    var button = UIButton()
    var defaultImage: UIImage? {
        didSet {
            self.defaultImgaeView.image = self.defaultImage
            self.defaultImgaeView.contentMode = UIViewContentMode.scaleAspectFit
        }
    }
    var defaultImgaeView = UIImageView()
    
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
        
        defaultImgaeView.backgroundColor = UIColor.black
        addSubview(defaultImgaeView)
        Layouter(superview: self, view: defaultImgaeView).edges()
        
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        addSubview(button)
        Layouter(superview: self, view: button).edges()
        
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
    
    var player: FFMpegPlayer?
    
    func play() {
        if player == nil {
            self.defaultImgaeView.isHidden = true
            player = FFMpegPlayer(view: imageView, delegate: self)
            player?.play()
        }
    }
    
    func stop() {
        player?.stop()
        player = nil
        self.defaultImgaeView.isHidden = false
    }
    
    func buttonAction() {
        if player == nil {
            play()
        } else {
            stop()
        }
    }
    
    // MARK: FFMpegPlayer Delegate
    
    var replay: Int = 3
    
    func FFMpegPlayerUrl() -> String {
        return rtspUrl
    }
    
    func FFMpegPlayerDidChangedStatus(_ status: FFMpegPlayerStatus) {
        if status == FFMpegPlayerStatus.loading {
            activity.startAnimating()
        } else {
            activity.stopAnimating()
        }
    }
    func FFMpegPlayerDidError(_ error: String) {
        player?.stop()
        player = nil
        activity.startAnimating()
        if replay > 0 {
            replay -= 1
            play()
        } else {
            Prompt.show(error: self, localized: "RTSP Play Error")
        }
    }

}

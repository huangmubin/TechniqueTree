//
//  FFMpegPlayer.swift
//  a10
//
//  Created by 黄穆斌 on 16/5/17.
//  Copyright © 2016年 Myron. All rights reserved.
//

import UIKit

enum FFMpegPlayerStatus {
    case Loading
    case Playing
    case Stoped
}

protocol FFMpegPlayerDelegate: NSObjectProtocol {
    func FFMpegPlayerUrl() -> String
    func FFMpegPlayerDidChangedStatus(status: FFMpegPlayerStatus)
    func FFMpegPlayerDidError(error: String)
}

class FFMpegPlayer: NSObject {
    
    // MARK: 初始化
    init(view: UIImageView, delegate: FFMpegPlayerDelegate) {
        super.init()
        self.containerView = view
        self.delegate = delegate
    }
    
    // MARK: 属性
    
    weak var delegate: FFMpegPlayerDelegate?
    var containerView: UIImageView!
    var status: FFMpegPlayerStatus = FFMpegPlayerStatus.Stoped {
        didSet {
            if delegate != nil {
                delegate?.FFMpegPlayerDidChangedStatus(status)
            } else {
                video = nil
            }
        }
    }
    var video: VideoFrameExtractor?
    var canBePlay = true
    
    // MARK: 方法
    func stop() {
        canBePlay = false
    }
    
    func play() {
        canBePlay = true
        guard let path = delegate?.FFMpegPlayerUrl() else { return }
        
        if path == "" {
            delegate?.FFMpegPlayerDidError("FFMpegPlayer : Path is Empty")
        }

        status = .Loading
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.video = VideoFrameExtractor(video: path)
            
            // 打开视频
            if self.video == nil {
                dispatch_async(dispatch_get_main_queue(), {
                    self.status = .Stoped
                    self.delegate?.FFMpegPlayerDidError("FFMpegPlayer : Video can't init.")
                })
                return
            }
            
            // 播放循环
            dispatch_async(dispatch_get_main_queue(), {
                self.status = .Playing
            })
            while self.canBePlay {
                if let image = self.nextFrameImage() {
                    if self.video?.isMiss() == false {
                        dispatch_sync(dispatch_get_main_queue(), {
                            self.containerView.image = image
                        })
                    }
//                    // TODO: jj
//                    dispatch_sync(dispatch_get_main_queue(), {
//                        self.containerView.image = image
//                    })
                } else {
                    dispatch_sync(dispatch_get_main_queue(), {
                        self.containerView.image = nil
                        self.delegate?.FFMpegPlayerDidChangedStatus(FFMpegPlayerStatus.Stoped)
                    })
                    break
                }
            }
            
            self.video = nil
        }
    }
    
    func nextFrameImage() -> UIImage? {
        if video?.stepFrame() != true {
            return nil
        }
        return video?.currentImage
    }
}

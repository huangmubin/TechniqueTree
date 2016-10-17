---
layout: post
title: "ijkplayer"
description: "关于 ijkplayer 库使用的记录。"
date: 2016-10-17
tags: [SDK,iOS,ijkplayer,播放器]
comments: true
share: false
---

https://github.com/Bilibili/ijkplayer

罗列了关于 ijkplayer 封装的主要方法，安装部分按 Github 上的文档操作即可。

# 主要加载方法

```
	var url: String = ""
    var player: IJKMediaPlayback?

    func loadVideo() {
        if player != nil { return }
        if url.isEmpty { return }
        
        IJKFFMoviePlayerController.setLogReport(false)
        IJKFFMoviePlayerController.setLogLevel(k_IJK_LOG_INFO)
        IJKFFMoviePlayerController.checkIfFFmpegVersionMatch(false)
        
        let options = IJKFFOptions.optionsByDefault()
        player = IJKFFMoviePlayerController(contentURLString: url, withOptions: options)
        
        if player == nil { return }
        
        player?.view.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.FlexibleWidth.rawValue | UIViewAutoresizing.FlexibleHeight.rawValue)
        player?.scalingMode = IJKMPMovieScalingMode.Fill
        player?.shouldAutoplay = false
        
        player?.view.userInteractionEnabled = false
        
        player?.view.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(player!.view, aboveSubview: imageView)
        for attr in [NSLayoutAttribute.Top, NSLayoutAttribute.Bottom, NSLayoutAttribute.Leading, NSLayoutAttribute.Trailing] {
            addConstraint(NSLayoutConstraint(item: player!.view, attribute: attr, relatedBy: .Equal, toItem: imageView, attribute: attr, multiplier: 1, constant: 0))
        }
    }
```


# 获取播放进度信息

```
    var progress: Double = 0 
    var timer: dispatch_source_t?
    
    func startTimer() {
        if timer != nil || player == nil { return }
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue())
        dispatch_source_set_timer(timer!, dispatch_walltime(nil, 0), NSEC_PER_SEC, 0)
        dispatch_source_set_event_handler(timer!) {
            if let player = self.player {
                if player.duration != 0 {
                    self.progress = player.currentPlaybackTime / player.duration
                }
            }
        }
        dispatch_resume(timer!)
    }
    
    func endTimer() {
        if timer == nil { return }
        dispatch_source_cancel(timer!)
        timer = nil
    }
```


# 监听视频事件

```
    func addNotify() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlayerLoadStateDidChangeNotification), name: IJKMPMoviePlayerLoadStateDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlayerPlaybackDidFinishNotification), name: IJKMPMoviePlayerPlaybackDidFinishNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaybackIsPreparedToPlayDidChangeNotification), name: IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlayerPlaybackStateDidChangeNotification), name: IJKMPMoviePlayerPlaybackStateDidChangeNotification, object: nil)
    }
    
    func removeNotify() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: IJKMPMoviePlayerLoadStateDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: IJKMPMoviePlayerPlaybackDidFinishNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: IJKMPMoviePlayerPlaybackStateDidChangeNotification, object: nil)
    }
    
    func PlayerLoadStateDidChangeNotification(sender: NSNotification) {
        guard sender.object === player else { return }
        
        let loadState = player!.loadState.rawValue
        if ((loadState & IJKMPMovieLoadState.PlaythroughOK.rawValue) != 0) {
            print("加载状态变化(\(url)): 加载流畅")
        } else if ((loadState & IJKMPMovieLoadState.Stalled.rawValue) != 0) {
            print("加载状态变化(\(url)): 加载暂停")
        } else {
            print("加载状态变化(\(url)): 未知状态")
        }
    }
    
    func PlayerPlaybackDidFinishNotification(sender: NSNotification) {
        guard sender.object === player else { return }
        
        let reason = Int(sender.userInfo![IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey]!.intValue)
        switch reason {
        case IJKMPMovieFinishReason.PlaybackEnded.rawValue:
            print("播放停止(\(url)): 播放结束")
        case IJKMPMovieFinishReason.UserExited.rawValue:
            print("播放停止(\(url)): 用户退出")
        case IJKMPMovieFinishReason.PlaybackError.rawValue:
            print("播放停止(\(url)): 播放错误")
        default:
            print("播放停止(\(url)): 未知原因")
        }
        stop()
    }
    
    func PlaybackIsPreparedToPlayDidChangeNotification(sender: NSNotification) {
        guard sender.object === player else { return }
        
        print("播放准备状态变化(\(url)): \(player?.isPreparedToPlay)")
        if player?.isPreparedToPlay == true {

        } else {
            
        }
    }
    
    func PlayerPlaybackStateDidChangeNotification(sender: NSNotification) {
        guard sender.object === player else { return }
        
        switch player!.playbackState {
        case IJKMPMoviePlaybackState.Stopped:
            print("播放状态变化(\(url)): Stopped")
        case IJKMPMoviePlaybackState.Playing:
            print("播放状态变化(\(url)): Playing")
        case IJKMPMoviePlaybackState.Paused:
            print("播放状态变化(\(url)): Paused")
        case IJKMPMoviePlaybackState.Interrupted:
            print("播放状态变化(\(url)): Interrupted")
        case IJKMPMoviePlaybackState.SeekingForward:
            print("播放状态变化(\(url)): SeekingForward")
        case IJKMPMoviePlaybackState.SeekingBackward:
            print("播放状态变化(\(url)): SeekingBackward")
        }
    }
```


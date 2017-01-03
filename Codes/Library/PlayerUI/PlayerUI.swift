//
//  PlayerUI.swift
//  Nightjar2
//
//  Created by 黄穆斌 on 2016/12/5.
//  Copyright © 2016年 Myron. All rights reserved.
//

import UIKit

// MARK: - Status

enum PlayerUIStatus {
    case image
    case video
    case loading
    case playing
    case stop
}

// MARK: - Protocol

protocol PlayerUIDelegate: NSObjectProtocol {
    var timeLength: CGFloat { get set }
    func playerUI(slider to: CGFloat)
    func playerUI(loading to: CGFloat)
    func playerUI(stop to: CGFloat)
}

// MARK: - Player UI

class PlayerUI: UIView {

    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initDeploy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initDeploy()
    }
    
    func initDeploy() {
        self.backgroundColor = UIColor.black
        self.clipsToBounds = true
        
        // Image
        addSubview(imageView)
        Layouter(superview: self, view: imageView).edges()
        
        // Button
        addSubview(button)
        button.isHidden = true
        button.addTarget(self, action: #selector(playButtonAction(_:)), for: UIControlEvents.touchUpInside)
        Layouter(superview: self, view: button).center().width(multiplier: 0.8).height(multiplier: 0.8)
        
        // Activity
        addSubview(activity)
        addSubview(label)
        label.shadowOffset = CGSize.zero
        label.shadowColor = UIColor.black
        label.textColor = UIColor.white
        activity.hidesWhenStopped = true
        activity.stopAnimating()
        Layouter(superview: self, view: label).center(x: 0, y: 16)
        Layouter(superview: self, view: activity, relative: label).centerX().layout(edge: .bottom, to: .top, constant: -16)
        
        // Progress
        addSubview(progressView)
        progressView.isHidden = true
        Layouter(superview: self, view: progressView).centerX().width().heightSelf(40).bottom().constrants(last: {
            self.progressViewBottomLayout = $0
        })
        
    }
    
    // MARK: - Datas
    
    var status = PlayerUIStatus.image {
        didSet { updateStatus() }
    }
    
    func updateStatus() {
        switch status {
        case .image:
            progressView.isHidden = true
            button.isHidden = true
        case .video:
            progressView.isHidden = false
            button.isHidden = false
            
            self.progressViewBottomLayout.constant = 80
            self.layoutIfNeeded()
            
            //progressAnimation(show: true)
            button.setImage(UIImage(named: "Play"), for: .normal)
        case .loading:
            image = nil
            
            progressAnimation(show: false)
            updatePrompt(text: "视频加载中", loading: true)
            
            delegate?.playerUI(loading: progress)
        case .playing:
            updatePrompt(text: "", loading: false)
        case .stop:
            
            updatePrompt(text: "", loading: false)
            progressAnimation(show: true)
            button.setImage(UIImage(named: "Play"), for: .normal)
            
            delegate?.playerUI(stop: progress)
        }
    }
    
    
    var progress: CGFloat = 0 {
        didSet {
            if !progressView.isTouching {
                progressView.progress = progress
            }
        }
    }
    
    weak var delegate: PlayerUIDelegate? {
        didSet {
            progressView.delegate = delegate
            progress = 0
        }
    }
    
    // MARK: - SubViews
    
    // MARK: Image
    
    var imageView = UIImageView()
    var image: UIImage? {
        get { return imageView.image }
        set { imageView.image = newValue }
    }
    
    // MAKR: Button
    
    var button = UIButton()
    func playButtonAction(_ sender: UIButton) {
        switch status {
        case .video, .stop:
            status = .loading
        case .loading, .playing:
            status = .stop
        default:
            break
        }
    }
    
    // MARK: Activiy
    
    var activity = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var label = UILabel(frame: CGRect.zero)
    
    func updatePrompt(text: String, loading: Bool) {
        label.text = text
        label.sizeToFit()
        if loading {
            activity.startAnimating()
        } else {
            activity.stopAnimating()
        }
        button.setImage(nil, for: .normal)
    }
    
    // MARK: Progress
    
    var progressView = PlayerUIProgressView(frame: CGRect.zero)
    var progressViewBottomLayout: NSLayoutConstraint!
    
    // MARK: Animation
    
    func progressAnimation(show: Bool) {
        UIView.animate(withDuration: 0.2, animations: {
            self.progressViewBottomLayout.constant = show ? 0 : self.progressView.frame.height
            
            self.progressView.sliderCenterYLayout.constant = show ? 0 : -self.progressView.frame.height / 2 - 1
            
            self.progressView.sliderWidthLayout.constant = show ? -80 : 0
            
            self.progressView.slider.slider.opacity = show ? 1 : 0
            
            self.layoutIfNeeded()
        })
    }
}

// MARK: - Player UI Progress View

class PlayerUIProgressView: UIView {
    
    // MARK: Data
    
    weak var delegate: PlayerUIDelegate?
    
    var progress: CGFloat {
        get {
            return slider.progress
        }
        set {
            slider.progress = newValue
            updateLabels(progress: newValue)
        }
    }
    
    var sliderCenterYLayout: NSLayoutConstraint!
    var sliderWidthLayout: NSLayoutConstraint!
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initDeploy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initDeploy()
    }
    
    private func initDeploy() {
        self.clipsToBounds = false
        layer.cornerRadius = 2
        layer.backgroundColor = UIColor.darkGray.cgColor
        
        // SubViews
        addSubview(leftLabel)
        leftLabel.font = UIFont.boldSystemFont(ofSize: 10)
        leftLabel.textColor = UIColor.white
        leftLabel.text = "00:00"
        Layouter(superview: self, view: leftLabel).centerY().leading(4)
        
        addSubview(rightLabel)
        rightLabel.font = UIFont.boldSystemFont(ofSize: 10)
        rightLabel.textColor = UIColor.white
        rightLabel.text = "00:00"
        Layouter(superview: self, view: rightLabel).centerY().trailing(-4)
        
        addSubview(slider)
        Layouter(superview: self, view: slider).height(-8).center().width(-80).constrants(block: { (layouts) in
            self.sliderCenterYLayout = layouts[2]
            self.sliderWidthLayout = layouts[3]
        })
    }
    
    // MARK: SubViews
    
    var slider = PlayerUISliderView(frame: CGRect.zero)
    
    var leftLabel = UILabel()
    var rightLabel = UILabel()
    
    func updateLabels(progress: CGFloat) {
        if let length = delegate?.timeLength {
            let current = length * progress
            leftLabel.text = "\(minute(time: current)):\(second(time: current))"
            rightLabel.text = "\(minute(time: length)):\(second(time: length))"
        }
    }
    
    private func minute(time: CGFloat) -> String {
        if Int(time) / 60 >= 10 {
            return String(format: "%d", Int(time) / 60)
        } else {
            return String(format: "0%d", Int(time) / 60)
        }
    }
    
    private func second(time: CGFloat) -> String {
        if Int(time) % 60 >= 10 {
            return String(format: "%d", Int(time) % 60)
        } else {
            return String(format: "0%d", Int(time) % 60)
        }
    }
    
    // MARK: - Touch
    
    var isTouching = false
    
    private func touchesAction(_ touches: Set<UITouch>, end: Bool) {
        isTouching = !end
        
        if let touch = touches.first {
            let x = touch.location(in: self).x
            switch x {
            case 0 ..< slider.frame.minX:
                progress = 0
            case slider.frame.minX ... slider.frame.maxX:
                progress = (x - slider.frame.minX) / slider.frame.width
            default:
                progress = 1
            }
        }
        
        if end {
            delegate?.playerUI(slider: progress)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesAction(touches, end: false)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesAction(touches, end: false)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesAction(touches, end: true)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesAction(touches, end: true)
    }
}

// MAKR: - Player UI Progress View

class PlayerUISliderView: UIView {
    
    // MARK: Layers
    
    let backLayer = CAShapeLayer()
    let lineLayer = CAShapeLayer()
    let slider = CAShapeLayer()
    
    // MARK: Datas
    
    var progress: CGFloat = 0 {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            lineLayer.strokeEnd = progress
            slider.position = CGPoint(x: bounds.width * progress, y: bounds.height/2)
            CATransaction.commit()
        }
    }
    var lineWidth: CGFloat = 2 {
        didSet {
            backLayer.lineWidth = lineWidth
            lineLayer.lineWidth = lineWidth
            
            layer.setNeedsDisplay()
        }
    }
    var sliderWidth: CGFloat = 2 {
        didSet {
            slider.frame = CGRect(x: 0, y: 0, width: sliderWidth, height: bounds.height)
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            slider.position = CGPoint(x: bounds.width * progress, y: bounds.height/2)
            CATransaction.commit()
            
            let path = UIBezierPath(roundedRect: slider.bounds, cornerRadius: sliderWidth/2)
            slider.path = path.cgPath
        }
    }
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initDeploy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initDeploy()
    }
    
    private func initDeploy() {
        self.backgroundColor = UIColor.clear
        
        //
        backLayer.strokeColor = UIColor.black.cgColor
        backLayer.lineCap = kCALineCapRound
        backLayer.lineWidth = lineWidth
        
        //
        lineLayer.strokeColor = UIColor.white.cgColor
        lineLayer.lineCap = kCALineCapRound
        lineLayer.lineWidth = lineWidth
        lineLayer.strokeEnd = 0
        
        //
        slider.fillColor = UIColor.white.cgColor
        //slider.strokeColor = UIColor.white.cgColor
        slider.shadowOffset = CGSize.zero
        slider.shadowOpacity = 0.5
        slider.shadowRadius = 1
        
        //
        layer.addSublayer(backLayer)
        layer.addSublayer(lineLayer)
        layer.addSublayer(slider)
    }
    
    func redeploy() {
        let _ = {
            backLayer.frame = bounds
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: bounds.height/2))
            path.addLine(to: CGPoint(x: bounds.width, y: bounds.height/2))
            backLayer.path = path.cgPath
        }()
        
        
        let _ = {
            lineLayer.frame = bounds
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: bounds.height/2))
            path.addLine(to: CGPoint(x: bounds.width, y: bounds.height/2))
            lineLayer.path = path.cgPath
        }()
        
        let _ = {
            slider.frame = CGRect(x: 0, y: 0, width: sliderWidth, height: bounds.height)
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            slider.position = CGPoint(x: bounds.width * progress, y: bounds.height/2)
            CATransaction.commit()
            
            let path = UIBezierPath(roundedRect: slider.bounds, cornerRadius: sliderWidth/2)
            slider.path = path.cgPath
        }()
        
        layer.setNeedsDisplay()
    }
    
    // MARK: Override
    
    override var frame: CGRect {
        didSet { redeploy() }
    }
    
    override var bounds: CGRect {
        didSet { redeploy() }
    }
    
}

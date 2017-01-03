//
//  Prompt.swift
//  Nightjar2
//
//  Created by 黄穆斌 on 2016/12/3.
//  Copyright © 2016年 Myron. All rights reserved.
//

import UIKit


public class Prompt: UIView {

    var color = Pallette.tint
    
    static var showingPrompt: Prompt?
    class func dismiss() {
        showingPrompt?.dismiss()
    }
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Data
    
    var label = UILabel()
    var imageView = UIImageView()
    
    var text: String?
    var time: TimeInterval?
    var finish: (() -> Void)?
    
    
    
    // MARK: Call
    
    func show(view: UIView?, text: String?, time: TimeInterval?, finish: (() -> Void)?) {
        guard let view = view else {
            return
        }
        
        //
        dismiss()
        
        // Property
        self.text = text
        self.time = time
        self.finish = finish
        Prompt.showingPrompt = self
        
        // Draw Background
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = 10
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.5
        
        // Label
        label.text = text
        label.textColor = color
        label.sizeToFit()
        addSubview(label)
        Layouter(superview: self, view: label).centerX().centerY(25)
        
        // ImageView
        addSubview(imageView)
        Layouter(superview: self, view: imageView).size(w: 36, h: 36).centerX().centerY(text == nil ? 0 : -10)
        
        // View
        view.addSubview(self)
        Layouter(superview: view, view: self).center().size(w: text == nil ? 90 : (label.bounds.width > 40 ? label.bounds.width + 40 : 90), h: 90)
        
        // SubViews
        drawSubViews()
        
        // Timer
        delayDismiss()
    }
    
    func dismiss() {
        if Prompt.showingPrompt != nil && Prompt.showingPrompt !== self {
            Prompt.showingPrompt?.dismiss()
        }
        timer?.cancel()
        timer = nil
        removeFromSuperview()
        Prompt.showingPrompt = nil
    }
    
    // MARK: Draw
    
    var heightLayout: NSLayoutConstraint!
    var widthLayout: NSLayoutConstraint!
    
    fileprivate func drawSubViews() { }
    
    // MARK: Show Time
    
    private var timer: DispatchSourceTimer?
    private func delayDismiss() {
        guard var timeOut = time else { return }
        timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: 1), queue: DispatchQueue.main)
        timer?.scheduleRepeating(wallDeadline: DispatchWallTime.now(), interval: DispatchTimeInterval.seconds(1))
        timer?.setEventHandler(handler: {
            if timeOut <= 0 {
                self.finish?()
                self.dismiss()
            } else {
                timeOut -= 1
            }
        })
        timer?.resume()
    }
    
    // MARK: Tools
    
    public class func show(view: UIView?, result: Bool, trueT: String? = nil, falseT: String? = nil, finish: (() -> Void)? = nil) {
        if result {
            PromptSuccess().show(view: view, text: trueT, finish: finish)
        } else {
            PromptError().show(view: view, text: falseT, finish: finish)
        }
    }
    
    public class func show(loding view: UIView?, localized: String?, isEnabled: Bool = false) {
        if let view = view {
            view.isUserInteractionEnabled = isEnabled
            PromptLoading().show(view: view, text: localized == nil ? nil : Tools.localized(localized!))
        }
    }
    
    public class func show(success view: UIView?, localized: String?, isEnabled: Bool = true, finish: (() -> Void)? = nil) {
        if let view = view {
            view.isUserInteractionEnabled = isEnabled
            PromptSuccess().show(view: view, text: localized == nil ? nil : Tools.localized(localized!), finish: finish)
        }
    }
    
    public class func show(error view: UIView?, localized: String?, isEnabled: Bool = true, finish: (() -> Void)? = nil) {
        if let view = view {
            view.isUserInteractionEnabled = isEnabled
            PromptError().show(view: view, text: localized == nil ? nil : Tools.localized(localized!), finish: finish)
        }
    }
    
    
}

// MAKR: - Prompt Success

class PromptSuccess: Prompt {
    
    func show(view: UIView?, text: String? = nil, finish: (() -> Void)? = nil) {
        super.show(view: view, text: text, time: 2, finish: finish)
    }
    
    fileprivate override func drawSubViews() {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 0)
        
        let path = UIBezierPath()
        
        // 圆形
        path.move(to: CGPoint(x: 36, y: 18))
        path.addArc(withCenter: CGPoint(x: 18, y: 18), radius: 17.5, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
        path.close()
        
        // Checkmark
        path.move(to: CGPoint(x: 10, y: 18))
        path.addLine(to: CGPoint(x: 16, y: 24))
        path.addLine(to: CGPoint(x: 27, y: 13))
        path.move(to: CGPoint(x: 10, y: 18))
        path.close()
        
        // Color
        color.setStroke()
        path.stroke()
        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}

// MAKR: - Prompt Error

class PromptError: Prompt {
    
    func show(view: UIView?, text: String? = nil, finish: (() -> Void)? = nil) {
        super.show(view: view, text: text, time: 2, finish: finish)
    }
    
    fileprivate override func drawSubViews() {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 0)
        
        let path = UIBezierPath()
        
        // 圆形
        path.move(to: CGPoint(x: 36, y: 18))
        path.addArc(withCenter: CGPoint(x: 18, y: 18), radius: 17.5, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
        path.close()
        
        // Error
        path.move(to: CGPoint(x: 10, y: 10))
        path.addLine(to: CGPoint(x: 26, y: 26))
        path.move(to: CGPoint(x: 10, y: 26))
        path.addLine(to: CGPoint(x: 26, y: 10))
        path.close()
        
        // Color
        color.setStroke()
        path.stroke()
        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}

// MAKR: - Prompt Loading

class PromptLoading: Prompt {
    
    func show(view: UIView, text: String? = nil) {
        super.show(view: view, text: text, time: nil, finish: nil)
    }
    
    fileprivate override func drawSubViews() {
        let active = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        active.color = color
        active.startAnimating()
        imageView.addSubview(active)
        Layouter(superview: imageView, view: active).center()
    }
}

//
//  ProgressBar.swift
//  ProgressBar
//
//  Created by 黄穆斌 on 2017/2/9.
//  Copyright © 2017年 黄穆斌. All rights reserved.
//

import UIKit

extension CGRect {
    
    func scale(_ size: CGFloat) -> CGRect {
        return CGRect(x: origin.x + size, y: origin.y + size, width: width - size - size, height: height - size - size)
    }
    
}

extension UIColor {
    
    convenience init(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1) {
        self.init(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
    
}

// MARK: - Progress Bar View

public class ProgressBar: UIView {
    
    // MARK: Value
    
    public var value: CGFloat = 0 {
        didSet {
            bar.value = value
            text.value = value
            self.text.center = CGPoint(x: self.bar.offset() + self.textOffset.x, y: self.textOffset.y)
        }
    }
    
    public var textOffset: CGPoint = CGPoint(x: 0, y: 0) {
        didSet {
            text.center = CGPoint(x: bar.offset() + textOffset.x, y: textOffset.y)
        }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initDeploy()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initDeploy()
    }
    
    private func initDeploy() {
        self.backgroundColor = UIColor.clear
        
        addSubview(bar)
        let cy = bounds.height / 2
        let h = CGFloat(20)
        bar.frame = CGRect(x: 0, y: cy - h / 2, width: bounds.width, height: h)
        
        addSubview(text)
        text.frame = CGRect(x: 0, y: 0, width: bounds.height, height: bounds.height)
        
        textOffset = CGPoint(x: 0, y: frame.height / 2)
    }
    
    // MARK: - Layer
    
    var bar: Bar = ProgressBar.Bar(frame: CGRect.zero)
    var text: Text = ProgressBar.Text(frame: CGRect.zero)
    
    // MARK: - Draw
    
    func draw() {
        let cy = bounds.height / 2
        let h = CGFloat(20)
        bar.frame = CGRect(x: 0, y: cy - h / 2, width: bounds.width, height: h)
        
        self.text.center = CGPoint(x: self.bar.offset() + self.textOffset.x, y: self.textOffset.y)
    }
    
    // MARK: - Frame
    
    override public var frame: CGRect {
        didSet {
            draw()
            textOffset = CGPoint(x: 0, y: frame.height / 2)
        }
    }
    
    override public var bounds: CGRect {
        didSet {
            draw()
            textOffset = CGPoint(x: 0, y: frame.height / 2)
        }
    }
    
}

// MARK: - Bar

extension ProgressBar {
    
    public class Bar: UIView {
        
        // MARK: Value
        
        /// 方向是否水平
        public var isHorizontal: Bool = true
        
        /// 背景栏
        public var backBar: CAGradientLayer = CAGradientLayer()
        public var backScale: CGFloat = 0 {
            didSet { update() }
        }
        
        /// 边栏
        public var edgeBar: CALayer = CALayer()
        public var edgeWidth: CGFloat = 2
        
        /// 值
        public var showBar: CAGradientLayer = CAGradientLayer()
        public var showBarMask: CAShapeLayer = CAShapeLayer()
        public var showScale: CGFloat = 6 {
            didSet { update() }
        }
        
        
        public var value: CGFloat = 0 {
            didSet { update(showFrame: value) }
        }
        
        // MARK: Init
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            deploy()
        }
        
        required public init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            deploy()
        }
        
        private func deploy() {
            // Back Bar
            layer.addSublayer(backBar)
            let backFrame = bounds.scale(backScale+2)
            backBar.frame = backFrame
            backBar.cornerRadius = isHorizontal ? backFrame.height / 2 : backFrame.width / 2
            backBar.shadowOffset = CGSize.zero
            backBar.shadowOpacity = 1
            backBar.shadowRadius = backScale
            backBar.startPoint = CGPoint(x: 0.5, y: 0)
            backBar.endPoint = CGPoint(x: 0.5, y: 1)
            
            update(backColors: [UIColor(38, 50, 56).cgColor, UIColor(69, 90, 100).cgColor])
            
            // Edge Bar
            layer.addSublayer(edgeBar)
            edgeBar.frame = bounds.scale(backScale)
            edgeBar.cornerRadius = backBar.cornerRadius + 1
            edgeBar.borderWidth = edgeWidth
            edgeBar.borderColor = UIColor(80,227,194).cgColor
            
            // ShowBar
            layer.addSublayer(showBar)
            let showFrame = bounds.scale(showScale)
            showBar.frame = showFrame
            showBar.shadowOffset = CGSize.zero
            showBar.shadowOpacity = 1
            showBar.shadowRadius = 2
            showBar.startPoint = CGPoint(x: 0, y: 0.5)
            showBar.endPoint = CGPoint(x: 1, y: 0.5)
            showBar.cornerRadius = isHorizontal ? showFrame.height / 2 : showFrame.width / 2
            update(showColors: [UIColor(142, 199, 81).cgColor, UIColor(243, 255, 227).cgColor])
        }
        
        // MARK: Update
        
        func update() {
            let backFrame = bounds.scale(backScale+2)
            backBar.frame = backFrame
            backBar.cornerRadius = isHorizontal ? backFrame.height / 2 : backFrame.width / 2
            
            edgeBar.frame = bounds.scale(backScale)
            edgeBar.cornerRadius = backBar.cornerRadius + 1
            
            let showFrame = bounds.scale(showScale)
            showBar.frame = showFrame
            showBar.cornerRadius = isHorizontal ? showFrame.height / 2 : showFrame.width / 2
            update(showFrame: value)
        }
        
        func update(showFrame value: CGFloat) {
            let showFrame = bounds.scale(showScale)
            let w = isHorizontal ? (showFrame.width - showFrame.height) * value + showFrame.height : showFrame.width
            let h = isHorizontal ? showFrame.height : (showFrame.height - showFrame.width) * value + showFrame.width
            showBar.frame = CGRect(x: showFrame.origin.x, y: showFrame.origin.y, width: w, height: h)
        }
        
        func update(backColors: [CGColor], location: [NSNumber]? = nil) {
            switch backColors.count {
            case 0, 1:
                backBar.backgroundColor = backColors.first
                backBar.colors = nil
            default:
                backBar.backgroundColor = nil
                backBar.colors = backColors
                backBar.locations = location
            }
        }
        
        func update(showColors: [CGColor], location: [NSNumber]? = nil) {
            switch showColors.count {
            case 0, 1:
                showBar.backgroundColor = showColors.first
                showBar.colors = nil
            default:
                showBar.backgroundColor = nil
                showBar.colors = showColors
                showBar.locations = location
            }
        }
        
        func offset() -> CGFloat {
            return showBar.frame.width + showBar.frame.origin.x + self.frame.origin.x - showBar.frame.height / 2
        }
        
        // MARK: Override
        
        public override var frame: CGRect { didSet { update() } }
        public override var bounds: CGRect { didSet { update() } }
        
    }
    
}

// MARK: - Text

extension ProgressBar {
    
    public class Text: UIView {
        
        // MARK: Value
        
        var value: CGFloat = 0 {
            didSet {
                label.text = prefix + String(format: format, value * 100) + suffix
            }
        }
        var format: String = "%.0f %%"
        var prefix: String = ""
        var suffix: String = ""
        var label: UILabel = UILabel()
        
        // MARK: Init
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            deploy()
        }
        
        required public init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            deploy()
        }
        
        func deploy() {
            addSubview(label)
            image(UIImage(named: "ProgressBarText"))
            label.textAlignment = NSTextAlignment.center
        }
        
        func image(_ im: UIImage?) {
            layer.contents = im?.cgImage
        }
        
        // MARK: Override
        
        public override var frame: CGRect {
            didSet {
                label.frame = bounds
            }
        }
        
        public override var bounds: CGRect {
            didSet {
                label.frame = bounds
            }
        }
        
        
    }
    
}

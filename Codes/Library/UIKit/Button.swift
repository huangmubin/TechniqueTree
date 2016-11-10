//
//  Button.swift
//  iOSTestProject
//
//  Created by 黄穆斌 on 16/11/10.
//  Copyright © 2016年 MuBinHuang. All rights reserved.
//

import UIKit

class Button: UIButton {
    
    // MARK: - Values
    
    // MARK: Note
    
    @IBInspectable var note: String = ""
    
    // MARK: Colors
    
    @IBInspectable var showColor: UIColor = UIColor.clear {
        didSet {
            layer.backgroundColor = isSelected ? tintColor.cgColor : showColor.cgColor
            backgroundColor = UIColor.clear
        }
    }
    
    // MARK: Shadow
    
    @IBInspectable var corner: CGFloat = 0 {
        didSet { layer.cornerRadius = corner }
    }
    
    @IBInspectable var opacity: Float = 0 {
        didSet { layer.shadowOpacity = opacity }
    }
    
    @IBInspectable var offset: CGPoint = CGPoint.zero {
        didSet { layer.shadowOffset = CGSize(width: offset.x, height: offset.y) }
    }
    
    @IBInspectable var radius: CGFloat = 0 {
        didSet { layer.shadowRadius = radius }
    }
    
    // MARK: - Override
    
    private var isBackImageViewRemoved: Bool = false
    
    override var isSelected: Bool {
        didSet {
            if !isBackImageViewRemoved {
                for view in subviews {
                    if view is UIImageView && view !== imageView {
                        isBackImageViewRemoved = true
                        view.removeFromSuperview()
                    }
                }
            }
            layer.backgroundColor = isSelected ? tintColor.cgColor : showColor.cgColor
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.layer.opacity = self.isHighlighted ? 0.3 : 1
            }
        }
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            if backgroundColor != UIColor.clear {
                showColor = backgroundColor ?? UIColor.clear
            }
        }
    }
    
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
        //layer.shadowOffset = CGSize(width: offset.x, height: offset.y)
        
        let select = self.isSelected
        self.isSelected = true
        self.isSelected = select
        
        let highlight = self.isHighlighted
        self.isHighlighted = true
        self.isHighlighted = highlight
    }
    
}

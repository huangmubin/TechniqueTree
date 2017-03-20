//
//  LittlePointView.swift
//  RangerCam2
//
//  Created by 黄穆斌 on 2017/1/10.
//  Copyright © 2017年 黄穆斌. All rights reserved.
//

import UIKit

class LittlePointView: UIView {

    
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
//        self.mask = UIView()
//        self.mask?.layer.backgroundColor = UIColor.blue.cgColor
//        self.mask?.frame = bounds
//        self.mask?.layer.cornerRadius = bounds.width / 2
        
        self.layer.cornerRadius = bounds.width / 2
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = 1
        
        self.backgroundColor = nil
        self.layer.backgroundColor = color.cgColor
        
        addSubview(numberlabel)
        numberlabel.text = "0"
        numberlabel.textColor = UIColor.white
        Layouter(superview: self, view: numberlabel).center()
        
        self.alpha = 0
    }
    
    override var frame: CGRect {
        didSet {
            self.layer.cornerRadius = bounds.width / 2
//            self.mask?.frame = bounds
//            self.mask?.layer.cornerRadius = bounds.width / 2
        }
    }
    
    override var bounds: CGRect {
        didSet {
            self.layer.cornerRadius = bounds.width / 2
//            self.mask?.frame = bounds
//            self.mask?.layer.cornerRadius = bounds.width / 2
        }
    }
    
    var numberlabel = UILabel()
    var animate: Bool = true
    var value: Int = 0 {
        didSet {
            numberlabel.text = "\(value)"
            if animate {                
                if value == 0 {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.alpha = 0
                    })
                } else if self.alpha != 1 {
                    self.alpha = 1
                }
            }
        }
    }
    
    @IBInspectable var color: UIColor = UIColor.blue {
        didSet {
            self.backgroundColor = nil
            self.layer.backgroundColor = color.cgColor
        }
    }
}

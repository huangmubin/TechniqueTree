//
//  UIKitExtensions.swift
//  Calendar
//
//  Created by 黄穆斌 on 2016/11/16.
//  Copyright © 2016年 Myron. All rights reserved.
//

import UIKit

// MARK: - UIViewController

extension UIViewController {
    
    var width: CGFloat {
        return self.view.bounds.width
    }
    var height: CGFloat {
        return self.view.bounds.height
    }
    var centerX: CGFloat {
        return self.view.bounds.width / 2
    }
    var centerY: CGFloat {
        return self.view.bounds.height / 2
    }
    
}

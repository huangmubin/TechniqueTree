//
//  GCD.swift
//  UISwift
//
//  Created by 黄穆斌 on 16/10/31.
//  Copyright © 2016年 MuBinHuang. All rights reserved.
//

import UIKit

class GCD: NSObject {
    
    func ddd() {
        let queue = DispatchQueue(label: "dd")
        queue.sync(flags: DispatchWorkItemFlags.barrier) {
            
        }
    }
    
}

//
//  TextInputView.swift
//  Calendar
//
//  Created by 黄穆斌 on 2016/11/23.
//  Copyright © 2016年 Myron. All rights reserved.
//

import UIKit

protocol TextInputViewDelegate: NSObjectProtocol {
    func textInputView(input: TextInputView, define text: String)
}

class TextInputView: UIView {
    
    // MAKR: - Delegate
    
    weak var delegate: TextInputViewDelegate?
    
    // MARK: - Text Field
    
    @IBOutlet weak var textField: UITextField!
    
    func textField(isFirstResponder: Bool) {
        if isFirstResponder {
            textField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
    }
    
    // MARK: - Define
    
    @IBAction func defineAction(_ sender: UIButton) {
        if textField.text?.isEmpty == false {
            delegate?.textInputView(input: self, define: textField.text!)
        }
        textField.text = nil
        textField.resignFirstResponder()
    }
    
}

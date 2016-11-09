//
//  Layout.swift
//  iOSTestProject
//
//  Created by 黄穆斌 on 16/11/9.
//  Copyright © 2016年 MuBinHuang. All rights reserved.
//

import UIKit

// MARK: - Layouter Class

/**
 自动布局类。
    Layouer: 主类。每次设置布局时创建
    Container: 副类。用于布局时存储 NSLayoutConstraint
 */
class Layouter {

    weak var superview: UIView!
    weak var view: UIView!
    weak var relative: UIView!
    
    // MARK: Init
    
    init(superview: UIView, view: UIView, relative: UIView? = nil, container: Layouter.Container? = nil) {
        self.superview = superview
        self.view = view
        self.relative = relative ?? superview
        self.view.translatesAutoresizingMaskIntoConstraints = true
        self._contrainer = container
    }
    
    func setViews(view: UIView? = nil, relative: UIView? = nil) -> Layouter {
        if let view = view {
            self.view = view
            self.view.translatesAutoresizingMaskIntoConstraints = true
        }
        if let view = relative {
            self.relative = view
        }
        return self
    }
    
    // MARK: Constraints
    
    /* 每次添加 Layout 之后，都会把生成的 NSLayoutConstraint 存储到 _constrants。除非 Layouter 被释放或主动调用 clearConstrants，否则不会被释放。 */
    
    fileprivate var _constrants: [NSLayoutConstraint] = []
    
    func clearConstrants() -> Layouter {
        _constrants.removeAll(keepingCapacity: true)
        return self
    }
    
    func constrants(block: ([NSLayoutConstraint]) -> Void) -> Layouter {
        block(_constrants)
        return self
    }
    
    func constrants(index: Int) -> NSLayoutConstraint {
        return _constrants[index]
    }
    
    // MARK: Contrainer
    
    /* 在设置 Layout 的中间进行 Container 添加操作。 */
    
    weak var _contrainer: Layouter.Container?
    
    func setContrainer(_ con: Layouter.Container) -> Layouter {
        _contrainer = con
        return self
    }
    
    func contrainer(index: Int, key: String) -> Layouter {
        _contrainer?.append(key: key, layout: _constrants[index])
        return self
    }
    
    func contrainer(key: String) -> Layouter {
        _contrainer?.append(key: key, layout: _constrants.last!)
        return self
    }
    
    func contrainer(_ block: (Int, NSLayoutConstraint) -> String?) -> Layouter {
        for (index, layout) in _constrants.enumerated() {
            if let key = block(index, layout) {
                _contrainer?.append(key: key, layout: layout)
            }
        }
        return self
    }
    
}

// MARK: Layout Container

extension Layouter {
    
    /**
     NSLayoutConstraint Container
     */
    class Container {
        
        var layouts: [String : NSLayoutConstraint]
        
        init(type: String) {
            layouts = [String : NSLayoutConstraint]()
        }
        
        subscript(key: String) -> NSLayoutConstraint? {
            return layouts[key]
        }
        
        func remove(key: String) {
            layouts.removeValue(forKey: key)
        }
        
        func clear() {
            layouts.removeAll()
        }
        
        func append(key: String, layout: NSLayoutConstraint) {
            layouts[key] = layout
        }
    }
    
}

// MARK: Customs Layout

extension Layouter {
    
    func layout(edge: NSLayoutAttribute, to: NSLayoutAttribute, constant: CGFloat = 0, multiplier: CGFloat = 1, priority: Float = 1000, related: NSLayoutRelation = .equal) -> Layouter {
        let lay = NSLayoutConstraint(item: view, attribute: edge, relatedBy: related, toItem: relative, attribute: to, multiplier: multiplier, constant: constant)
        lay.priority = priority
        superview.addConstraint(lay)
        _constrants.append(lay)
        return self
    }
    
}

// MARK: Predefined Layout: Size

extension Layouter {
    
    /// When related is nil, height is view's height layout, or not, height is view's height layout to superview's height.
    func height(constant: CGFloat = 0, multiplier: CGFloat = 1, priority: Float = 1000, related: NSLayoutRelation? = nil) -> Layouter {
        if let r = related {
            let lay = NSLayoutConstraint(item: view, attribute: .height, relatedBy: r, toItem: superview, attribute: .height, multiplier: multiplier, constant: constant)
            lay.priority = priority
            superview.addConstraint(lay)
            _constrants.append(lay)
        } else {
            let lay = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: constant)
            lay.priority = priority
            superview.addConstraint(lay)
            _constrants.append(lay)
        }
        return self
    }
    
    /// When related is nil, width is view's width layout, or not, width is view's width layout to superview's width.
    func width(constant: CGFloat = 0, multiplier: CGFloat = 1, priority: Float = 1000, related: NSLayoutRelation? = nil) -> Layouter {
        if let r = related {
            let lay = NSLayoutConstraint(item: view, attribute: .width, relatedBy: r, toItem: superview, attribute: .width, multiplier: multiplier, constant: constant)
            lay.priority = priority
            superview.addConstraint(lay)
            _constrants.append(lay)
        } else {
            let lay = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: constant)
            lay.priority = priority
            superview.addConstraint(lay)
            _constrants.append(lay)
        }
        return self
    }
    
    /// Type true is width to height, false is height to width
    func aspect(type: Bool = true, constant: CGFloat = 0, multiplier: CGFloat = 1, priority: Float = 1000, related: NSLayoutRelation = .equal) -> Layouter {
        let lay = NSLayoutConstraint(item: view, attribute: type ? .width : .height, relatedBy: related, toItem: view, attribute: type ? .height : .width, multiplier: multiplier, constant: constant)
        lay.priority = priority
        superview.addConstraint(lay)
        _constrants.append(lay)
        return self
    }
    
    /// width and height
    func size(w: CGFloat, h: CGFloat, priority: Float = 1000) -> Layouter {
        let _ = {
            let lay = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: w)
            lay.priority = priority
            superview.addConstraint(lay)
            _constrants.append(lay)
        }()
        let _ = {
            let lay = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: h)
            lay.priority = priority
            superview.addConstraint(lay)
            _constrants.append(lay)
        }()
        return self
    }
    
}

// MARK: Predefined Layout: Single Layout

extension Layouter {
    
    func top(_ constant: CGFloat = 0, multiplier: CGFloat = 1, priority: Float = 1000, related: NSLayoutRelation = .equal) -> Layouter {
        let lay = NSLayoutConstraint(item: view, attribute: .top, relatedBy: related, toItem: superview, attribute: .top, multiplier: multiplier, constant: constant)
        lay.priority = priority
        superview.addConstraint(lay)
        _constrants.append(lay)
        return self
    }
    
    func bottom(_ constant: CGFloat = 0, multiplier: CGFloat = 1, priority: Float = 1000, related: NSLayoutRelation = .equal) -> Layouter {
        let lay = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: related, toItem: superview, attribute: .bottom, multiplier: multiplier, constant: constant)
        lay.priority = priority
        superview.addConstraint(lay)
        _constrants.append(lay)
        return self
    }
    
    func leading(_ constant: CGFloat = 0, multiplier: CGFloat = 1, priority: Float = 1000, related: NSLayoutRelation = .equal) -> Layouter {
        let lay = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: related, toItem: superview, attribute: .leading, multiplier: multiplier, constant: constant)
        lay.priority = priority
        superview.addConstraint(lay)
        _constrants.append(lay)
        return self
    }
    
    func trailing(_ constant: CGFloat = 0, multiplier: CGFloat = 1, priority: Float = 1000, related: NSLayoutRelation = .equal) -> Layouter {
        let lay = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: related, toItem: superview, attribute: .trailing, multiplier: multiplier, constant: constant)
        lay.priority = priority
        superview.addConstraint(lay)
        _constrants.append(lay)
        return self
    }
    
    func centerX(_ constant: CGFloat = 0, multiplier: CGFloat = 1, priority: Float = 1000, related: NSLayoutRelation = .equal) -> Layouter {
        let lay = NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: related, toItem: superview, attribute: .centerX, multiplier: multiplier, constant: constant)
        lay.priority = priority
        superview.addConstraint(lay)
        _constrants.append(lay)
        return self
    }
    
    func centerY(_ constant: CGFloat = 0, multiplier: CGFloat = 1, priority: Float = 1000, related: NSLayoutRelation = .equal) -> Layouter {
        let lay = NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: related, toItem: superview, attribute: .centerY, multiplier: multiplier, constant: constant)
        lay.priority = priority
        superview.addConstraint(lay)
        _constrants.append(lay)
        return self
    }
    
}

// MARK: Predefined Layout: Double Layout

extension Layouter {
    
    func center(x: CGFloat = 0, y: CGFloat = 0) -> Layouter {
        let _ = {
            let lay = NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: superview, attribute: .centerX, multiplier: 1, constant: x)
            superview.addConstraint(lay)
            _constrants.append(lay)
        }()
        let _ = {
            let lay = NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: superview, attribute: .centerY, multiplier: 1, constant: y)
            superview.addConstraint(lay)
            _constrants.append(lay)
        }()
        return self
    }
    
    func horizontal(leading: CGFloat = 0, trailing: CGFloat = 0) -> Layouter {
        let _ = {
            let lay = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: superview, attribute: .leading, multiplier: 1, constant: leading)
            superview.addConstraint(lay)
            _constrants.append(lay)
        }()
        let _ = {
            let lay = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: superview, attribute: .trailing, multiplier: 1, constant: trailing)
            superview.addConstraint(lay)
            _constrants.append(lay)
        }()
        return self
    }
    
    func vertical(top: CGFloat = 0, bottom: CGFloat = 0) -> Layouter {
        let _ = {
            let lay = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: superview, attribute: .top, multiplier: 1, constant: top)
            superview.addConstraint(lay)
            _constrants.append(lay)
        }()
        let _ = {
            let lay = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: superview, attribute: .bottom, multiplier: 1, constant: bottom)
            superview.addConstraint(lay)
            _constrants.append(lay)
        }()
        return self
    }
    
}


// MARK: Predefined Layout: Four Layout

extension Layouter {

    func edges(top: CGFloat = 0, bottom: CGFloat = 0, leading: CGFloat, trailing: CGFloat = 0) -> Layouter {
        let _ = {
            let lay = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: superview, attribute: .top, multiplier: 1, constant: top)
            superview.addConstraint(lay)
            _constrants.append(lay)
        }()
        let _ = {
            let lay = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: superview, attribute: .bottom, multiplier: 1, constant: bottom)
            superview.addConstraint(lay)
            _constrants.append(lay)
        }()
        let _ = {
            let lay = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: superview, attribute: .leading, multiplier: 1, constant: leading)
            superview.addConstraint(lay)
            _constrants.append(lay)
        }()
        let _ = {
            let lay = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: superview, attribute: .trailing, multiplier: 1, constant: trailing)
            superview.addConstraint(lay)
            _constrants.append(lay)
        }()
        return self
    }
    
}
/*
// MARK: - Layout Operations

extension Layouter {
 
    /*
     通过运算付来进行 Layout 设置。
     */
    class Operation {
        weak var view: UIView!
        var attribute: NSLayoutAttribute
        
        var constant: CGFloat = 0
        var multiplier: CGFloat = 1
        var priority: Float = 1000
        
        init(view: UIView, attribute: NSLayoutAttribute) {
            self.view = view
            self.attribute = attribute
        }
    }
    
}

// MARK: - Layout Operations: == <= >=

extension Layouter.Operation {
    
    static func ==(left: Layouter.Operation, right: Layouter.Operation) -> NSLayoutConstraint {
        left.view.translatesAutoresizingMaskIntoConstraints = false
        let layout = NSLayoutConstraint(item: left.view, attribute: left.attribute, relatedBy: .equal, toItem: right.view, attribute: right.attribute, multiplier: right.multiplier, constant: right.constant)
        layout.priority = right.priority
        return layout
    }
    
    static func <=(left: Layouter.Operation, right: Layouter.Operation) -> NSLayoutConstraint {
        left.view.translatesAutoresizingMaskIntoConstraints = false
        let layout = NSLayoutConstraint(item: left.view, attribute: left.attribute, relatedBy: .lessThanOrEqual, toItem: right.view, attribute: right.attribute, multiplier: right.multiplier, constant: right.constant)
        layout.priority = right.priority
        return layout
    }
    
    static func >=(left: Layouter.Operation, right: Layouter.Operation) -> NSLayoutConstraint {
        left.view.translatesAutoresizingMaskIntoConstraints = false
        let layout = NSLayoutConstraint(item: left.view, attribute: left.attribute, relatedBy: .greaterThanOrEqual, toItem: right.view, attribute: right.attribute, multiplier: right.multiplier, constant: right.constant)
        layout.priority = right.priority
        return layout
    }
    
}

// MARK: - Layout Operations: + - * / |

extension Layouter.Operation {
    
    static func +(left: Layouter.Operation, right: CGFloat) -> Layouter.Operation {
        left.constant = right
        return left
    }
    
    static func -(left: Layouter.Operation, right: CGFloat) -> Layouter.Operation {
        left.constant = -right
        return left
    }
    
    static func *(left: Layouter.Operation, right: CGFloat) -> Layouter.Operation {
        left.multiplier = right
        return left
    }
    
    static func /(left: Layouter.Operation, right: CGFloat) -> Layouter.Operation {
        left.multiplier = 1/right
        return left
    }
    
    static func |(left: Layouter.Operation, right: Float) -> Layouter.Operation {
        left.priority = right
        return left
    }
    
}

// MARK: - Layout Operations Protocol

extension UIView {
    
    var width: Layouter.Operation {
        return Layouter.Operation(view: self, attribute: .width)
    }
    
    var height: Layouter.Operation {
        return Layouter.Operation(view: self, attribute: .height)
    }
    
    var centerX: Layouter.Operation {
        return Layouter.Operation(view: self, attribute: .centerX)
    }
    
    var centerY: Layouter.Operation {
        return Layouter.Operation(view: self, attribute: .centerY)
    }
    
    var top: Layouter.Operation {
        return Layouter.Operation(view: self, attribute: .top)
    }
    
    var bottom: Layouter.Operation {
        return Layouter.Operation(view: self, attribute: .bottom)
    }
    
    var leading: Layouter.Operation {
        return Layouter.Operation(view: self, attribute: .leading)
    }
    
    var trailing: Layouter.Operation {
        return Layouter.Operation(view: self, attribute: .trailing)
    }
    
}
*/

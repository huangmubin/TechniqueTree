//
//  EasyViewer.swift
//  EasyViewer
//
//  Created by 黄穆斌 on 2017/2/28.
//  Copyright © 2017年 MubinHuang. All rights reserved.
//

import UIKit

// MARK: - Easy Viewer Sub View

enum EasyViewerSubViewType {
    case view
    case header
    case footer
}

class EasyViewerSubView: UIView {
    
    var type: EasyViewerSubViewType = .view
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    init(type: EasyViewerSubViewType = EasyViewerSubViewType.view) {
        super.init(frame: CGRect.zero)
        self.type = type
    }
    
    var _deploy = true
    var index: Int = 0
    var data: Any?
    weak var eventObject: AnyObject?
    func deploy() {
        if _deploy {
            _deploy = false
            loadView()
        }
        update()
    }
    func loadView() {
        
    }
    func update() {
        
    }
    func resize() {
        
    }
    
    override var frame: CGRect {
        didSet {
            resize()
        }
    }
    
    override var bounds: CGRect {
        didSet {
            resize()
        }
    }
    
}

// MARK: - Easy Viewer Model

protocol EasyViewerModelProtocol {
    var index: Int { get set }
    
    // MARK: Action
    
    func backEvent(index: Int)
    func deleteEvent(index: Int)
    
    // MARK: Move
    
    func moveBack(index: Int) -> CGRect
    func moveToFront(index: Int) -> Bool
    func moveToNext(index: Int) -> Bool
    
    // MARK: Datas
    
    func viewData(index: Int) -> Any?
    func viewEventObject(index: Int) -> AnyObject?
}

class EasyViewerModel: EasyViewerModelProtocol {
    
    var index: Int = 0
    
    // MARK: Action
    
    func backEvent(index: Int) {
        
    }
    
    func deleteEvent(index: Int) {
        
    }
    
    // MARK: Move
    
    func moveBack(index: Int) -> CGRect {
        return CGRect.zero
    }
    
    func moveToFront(index: Int) -> Bool {
        return false
    }
    
    func moveToNext(index: Int) -> Bool {
        return false
    }
    
    // MARK: Datas
    
    func viewData(index: Int) -> Any? {
        return nil
    }
    func viewEventObject(index: Int) -> AnyObject? {
        return nil
    }
    
}

// MARK: - Image Easy Viewer

class EasyViewerImageSubView: EasyViewerSubView {
    
    var imageView: UIImageView = UIImageView()
    override func loadView() {
        addSubview(imageView)
        imageView.contentMode = UIViewContentMode.scaleAspectFit
    }
    override func update() {
        imageView.image = data as? UIImage
    }
    
    func update(size: CGRect) {
        imageView.frame = size
    }
    
    override var frame: CGRect {
        didSet {
            update(size: bounds)
        }
    }
    override var bounds: CGRect {
        didSet {
            update(size: bounds)
        }
    }
    
}

protocol EasyViewerImageDelegate: NSObjectProtocol {
    
    func easyViewerImageBackEvent(index: Int)
    func easyViewerImageBackRect(index: Int) -> CGRect
}

class EasyViewerImageModel: EasyViewerModel {
    
    var images: [UIImage] = []
    var backRect: CGRect = CGRect.zero
    weak var delegate: EasyViewerImageDelegate?
    
    override func backEvent(index: Int) {
        delegate?.easyViewerImageBackEvent(index: index)
    }
    
    override func moveBack(index: Int) -> CGRect {
        return delegate?.easyViewerImageBackRect(index: index) ?? backRect
    }
    
    override func moveToFront(index: Int) -> Bool {
        if index <= 0 {
            return false
        } else if index >= images.count {
            return false
        } else {
            return true
        }
    }
    
    override func moveToNext(index: Int) -> Bool {
        if index < 0 {
            return false
        } else if index > images.count - 2 {
            return false
        } else {
            return true
        }
    }
    
    override func viewData(index: Int) -> Any? {
        if index < 0 {
            return nil
        } else if index >= images.count {
            return nil
        } else {
            return images[index]
        }
    }
    
    override func deleteEvent(index: Int) {
        if index >= 0 && index < images.count {
            images.remove(at: index)
        }
    }
    
}

// MARK: - Easy Viewer

class EasyViewer: UIView {
    
    deinit {
        print("EasyViewer deinit")
    }
    // MARK: Value
    
    var limitBig: CGFloat = 2
    var contentRatio: CGFloat = 1
    var headerHeight: CGFloat = 0
    var footerHeight: CGFloat = 0
    
    // MARK: Method
    
    func setModel(images: [UIImage]) {
        let iModel = EasyViewerImageModel()
        iModel.images = images
        model = iModel
        
        views.a = EasyViewerImageSubView()
        views.b = EasyViewerImageSubView()
        views.c = EasyViewerImageSubView()
    }
    
    func delete() {
        let rect = CGRect(x: bounds.width / 2, y: bounds.height / 2, width: 0, height: 0)
        UIView.animate(withDuration: 0.25, animations: { 
            self.views.b.frame = rect
            self.views.b.alpha = 0.5
        }, completion: { _ in
            self.views.b.alpha = 1
            let i = self.model.index
            if self.model.moveToNext(index: i) {
                self.model.deleteEvent(index: i)
                self.model.index -= 1
                self.moveToNext()
                return
            }
            if self.model.moveToFront(index: i) {
                self.model.deleteEvent(index: i)
                self.moveToFront()
                return
            }
            self.model.deleteEvent(index: i)
            self.model.index -= 1
            self.loadData()
            self.rectReset()
        })
    }
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func deploy() {
        self.isUserInteractionEnabled = true
        addSubview(backgroundView)
        backgroundView.frame = bounds
        backgroundView.backgroundColor = UIColor.black
        
        addSubview(views.a)
        addSubview(views.b)
        addSubview(views.c)
        
        addSubview(views.header)
        addSubview(views.footer)
        views.reset(bounds, header: headerHeight, footer: footerHeight)
        loadData()
        
        tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        double = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction))
        pan = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction))
        double.numberOfTapsRequired = 2
        tap.require(toFail: double)
        
        addGestureRecognizer(tap)
        addGestureRecognizer(double)
        addGestureRecognizer(pan)
        addGestureRecognizer(pinch)
        
    }
    
    // MARK: Views
    
    struct Views {
        var a = EasyViewerSubView()
        var b = EasyViewerSubView()
        var c = EasyViewerSubView()
        
        var header = EasyViewerSubView(type: .header)
        var footer = EasyViewerSubView(type: .footer)
        
        func reset(_ rect: CGRect, header: CGFloat, footer: CGFloat) {
            a.frame = CGRect(x: rect.origin.x - rect.width - 10, y: rect.origin.y, width: rect.width, height: rect.height)
            b.frame = rect
            c.frame = CGRect(x: rect.origin.x + rect.width + 10, y: rect.origin.y, width: rect.width, height: rect.height)
            
            self.header.frame = CGRect(x: 0, y: 0, width: rect.width, height: header)
            self.footer.frame = CGRect(x: 0, y: rect.height - footer, width: rect.width, height: footer)
        }
        
        func update() {
            a.deploy()
            b.deploy()
            c.deploy()
            
            header.deploy()
            footer.deploy()
        }
        
        func header_footer_animation(show: Bool, animate: Bool) {
            if animate {
                UIView.animate(withDuration: 0.25) {
                    self.header.alpha = show ? 1 : 0
                    self.footer.alpha = show ? 1 : 0
                }
            } else {
                self.header.alpha = show ? 1 : 0
                self.footer.alpha = show ? 1 : 0
            }
        }
    }
    var views = Views()
    var backgroundView = UIView()
    
    // MARK: Model
    
    var model: EasyViewerModelProtocol = EasyViewerModel()
    
    func loadData() {
        views.a.data = model.viewData(index: model.index - 1)
        views.b.data = model.viewData(index: model.index)
        views.c.data = model.viewData(index: model.index + 1)
        
        views.a.eventObject = model.viewEventObject(index: model.index - 1)
        views.b.eventObject = model.viewEventObject(index: model.index)
        views.c.eventObject = model.viewEventObject(index: model.index + 1)
        
        views.header.data = views.b.data
        views.footer.data = views.b.data
        views.header.eventObject = views.b.eventObject
        views.footer.eventObject = views.b.eventObject
        
        views.update()
    }
    
    // MARK: Override
    
    override var bounds: CGRect {
        didSet {
            rectReset()
            backgroundView.frame = bounds
        }
    }
    
    override var frame: CGRect {
        didSet {
            rectReset()
            backgroundView.frame = bounds
        }
    }
    
    // MARK: Frame Tools
    
    func rect(offset: CGRect, x: CGFloat = 0, y: CGFloat = 0) -> CGRect {
        return CGRect(x: offset.origin.x + x, y: offset.origin.y + y, width: offset.width, height: offset.height)
    }
    
    func rectReset(_ animate: Bool = true) {
        if animate {
            UIView.animate(withDuration: 0.25) { [bounds = self.bounds] in
                self.views.a.frame = self.rect(offset: bounds, x: -bounds.width - 10)
                self.views.b.frame = bounds
                self.views.c.frame = self.rect(offset: bounds, x: bounds.width + 10)
                
                self.views.header.frame = CGRect(x: 0, y: 0, width: bounds.width, height: self.headerHeight)
                self.views.footer.frame = CGRect(x: 0, y: bounds.height - self.footerHeight, width: bounds.width, height: self.footerHeight)
            }
        } else {
            self.views.a.frame = self.rect(offset: bounds, x: -bounds.width - 10)
            self.views.b.frame = bounds
            self.views.c.frame = self.rect(offset: bounds, x: bounds.width + 10)
            
            self.views.header.frame = CGRect(x: 0, y: 0, width: bounds.width, height: self.headerHeight)
            self.views.footer.frame = CGRect(x: 0, y: bounds.height - self.footerHeight, width: bounds.width, height: self.footerHeight)
        }
    }
    
    func rectAdjust() {
        var rect = bounds
        var isTooSmall = false
        
        // Size
        if views.b.bounds.width > bounds.width * limitBig {
            // too big
            rect.size.width = bounds.width * limitBig
            rect.size.height = bounds.height * limitBig
        } else if views.b.bounds.width >= bounds.width {
            // middle
            rect.size.width = views.b.bounds.width
            rect.size.height = views.b.bounds.height
        } else {
            // too small
            isTooSmall = true
        }
        
        // Origin
        // If is too small, don't need to adjust x and y.
        if !isTooSmall {
            // 1, count the scale.
            let x = (-views.b.frame.origin.x + bounds.width / 2) / views.b.bounds.width
            let y = (-views.b.frame.origin.y + bounds.height / 2) / views.b.bounds.height
            rect.origin.x = bounds.width / 2 - rect.size.width * x
            rect.origin.y = bounds.height / 2 - rect.size.height * y
            
            // 2, adjust the edge x.
            if rect.origin.x >= 0 {
                rect.origin.x = 0
            } else {
                let sx = bounds.width - rect.width
                if rect.origin.x < sx {
                    rect.origin.x = sx
                }
            }
            
            /*
             // 3, adjust the edge y
            if rect.origin.y >= 0 {
                rect.origin.y = 0
            } else {
                let sy = bounds.height - rect.height
                if rect.origin.y < sy {
                    rect.origin.y = sy
                }
            }
            */
            
            // 3, adjust the edge y
            let contentHeight = rect.height * contentRatio
            let offset = (rect.height - max(contentHeight, bounds.height)) / 2
            if rect.origin.y >= -offset {
                rect.origin.y = -offset
            } else {
                let sy = bounds.height - (rect.height - offset)
                if rect.origin.y < sy {
                    rect.origin.y = sy
                }
            }
        }
        
        // Animation
        UIView.animate(withDuration: 0.25) { 
            self.views.b.frame = rect
            self.views.a.frame.origin.x = rect.minX - 10 - self.views.a.bounds.width
            self.views.c.frame.origin.x = rect.maxX + 10
        }
    }
    
    // MARK: Gesture
    
    var tap: UITapGestureRecognizer!
    func tapAction(gesture: UITapGestureRecognizer) {
        let rect = model.moveBack(index: model.index)
        backgroundView.alpha = 0
        UIView.animate(withDuration: 0.25, animations: { 
            self.views.b.frame = rect
        }, completion: { _ in
            self.model.backEvent(index: self.model.index)
            self.backgroundView.alpha = 1
            self.rectReset(false)
        })
    }
    
    var double: UITapGestureRecognizer!
    func doubleTapAction(gesture: UITapGestureRecognizer) {
        if self.views.b.frame.width == self.bounds.width * limitBig {
            self.rectReset()
        } else {
            let w = self.bounds.width * self.limitBig
            let h = self.bounds.height * self.limitBig
            let x = -(w - self.bounds.width) / 2
            let y = -(h - self.bounds.height) / 2
            
            UIView.animate(withDuration: 0.25, animations: { 
                self.views.b.frame = CGRect(x: x, y: y, width: w, height: h)
            })
        }
    }
    
    var pan: UIPanGestureRecognizer!
    var panRect: CGRect = CGRect.zero
    var panAC: CGPoint = CGPoint.zero
    var panIsVertical: Bool? = nil
    func panAction(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            // MARK: Pan Began
            views.a.frame.origin.x = views.b.frame.origin.x - 10 - views.a.bounds.width
            views.c.frame.origin.x = views.b.frame.maxX + 10
            panRect = views.b.frame
            panAC = CGPoint(x: views.a.frame.origin.x, y: views.c.frame.origin.x)
            panIsVertical = nil
            
            // Header Footer
            views.header_footer_animation(show: false, animate: false)
        case .changed:
            // MARK: Pan Changed
            let offset = gesture.translation(in: self)
            
            // Pan Direction
            if panIsVertical == nil {
                if gesture.velocity(in: self).y > 700 {
                    panIsVertical = abs(offset.y) > abs(offset.x) && offset.y > 0
                } else {
                    panIsVertical = false
                }
            }
            
            if panIsVertical == false {
                // MARK: Horizontal Pan
                // Pan x
                views.b.frame.origin.x = panRect.origin.x + offset.x
                views.a.frame.origin.x = panAC.x + offset.x
                views.c.frame.origin.x = panAC.y + offset.x
                
                // Pan y
                let heightSpace = views.b.frame.height - bounds.height
                let newY = panRect.origin.y + offset.y
                if heightSpace > 0 {
                    // View Size is big
                    if newY > 0 {
                        views.b.frame.origin.y = newY * 0.2
                    } else if newY < -heightSpace {
                        let s = heightSpace + newY
                        views.b.frame.origin.y = -heightSpace + s * 0.2
                    } else {
                        views.b.frame.origin.y = newY
                    }
                } else {
                    views.b.frame.origin.y = newY * 0.2
                }
            } else {
                // MARK: Vertical Pan
                var scale = (panRect.height - offset.y) / panRect.height
                scale = scale > 1 ? 1 : scale
                
                backgroundView.alpha = scale
                
                views.b.bounds.size.width = panRect.width * scale
                views.b.bounds.size.height = panRect.height * scale
                views.b.center.x = panRect.midX + offset.x
                let y = panRect.midY + offset.y
                let c = bounds.height / 2
                views.b.center.y = y < c ? c - (c - y) * 0.3 : y
            }
        case .ended:
            // MARK: Pan Ended
            let velocity = gesture.velocity(in: self)
            
            // Back Out
            if panIsVertical == true {
                if backgroundView.alpha < 0.4 || velocity.y > 1000 {
                    let rect = model.moveBack(index: model.index)
                    UIView.animate(withDuration: 0.25, animations: {
                        self.views.b.frame = rect
                        self.backgroundView.alpha = 0
                    }, completion: { _ in
                        self.model.backEvent(index: self.model.index)
                        self.backgroundView.alpha = 1
                        self.rectReset(false)
                        self.views.header_footer_animation(show: true, animate: false)
                    })
                } else {
                    UIView.animate(withDuration: 0.25, animations: { 
                        self.views.b.frame = self.panRect
                        self.backgroundView.alpha = 1
                    }, completion: { _ in
                        self.views.header_footer_animation(show: true, animate: true)
                    })
                }
                return
            }
            
            // Move to front
            if views.a.frame.maxX > backgroundView.center.x || velocity.x > 1000 {
                if model.moveToFront(index: model.index) {
                    self.moveToFront()
                    return
                }
            }
            
            // Move to next
            if views.c.frame.minX < backgroundView.center.x || velocity.x < -1000 {
                if model.moveToNext(index: model.index) {
                    self.moveToNext()
                    return
                }
            }
            
            // Nothing
            rectAdjust()
            self.views.header_footer_animation(show: true, animate: true)
        default:
            break
        }
    }
    
    var pinch: UIPinchGestureRecognizer!
    var pinchFrame: CGRect = CGRect.zero
    var pinchCenter: CGPoint = CGPoint.zero
    var pinchMove: CGPoint! = nil
    var pinchOrigin: CGPoint = CGPoint.zero
    func pinchAction(gesture: UIPinchGestureRecognizer) {
        func center(_ p1: CGPoint, _ p2: CGPoint) -> CGPoint {
            return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
        }
        
        switch gesture.state {
        case .began:
            // MARK: Pinch Began
            pinchFrame = views.b.frame
            let c = center(gesture.location(ofTouch: 0, in: views.b), gesture.location(ofTouch: 1, in: views.b))
            pinchCenter = CGPoint(
                x: c.x / pinchFrame.width,
                y: c.y / pinchFrame.height
            )
            
            self.views.header_footer_animation(show: false, animate: false)
        case .changed:
            // MARK: Pinch Changed
            if gesture.numberOfTouches > 1 {
                let c = center(gesture.location(ofTouch: 0, in: self), gesture.location(ofTouch: 1, in: self))
                
                let w = pinchFrame.width * gesture.scale
                let h = pinchFrame.height * gesture.scale
                
                views.b.frame = CGRect(
                    x: c.x - w * pinchCenter.x,
                    y: c.y - h * pinchCenter.y,
                    width: w,
                    height: h
                )
            } else {
                if pinchMove == nil {
                    pinchOrigin = views.b.frame.origin
                    pinchMove = gesture.location(ofTouch: 0, in: self)
                } else {
                    let m = gesture.location(ofTouch: 0, in: self)
                    views.b.frame.origin.x = m.x - pinchMove.x + pinchOrigin.x
                    views.b.frame.origin.y = m.y - pinchMove.y + pinchOrigin.y
                }
            }
        case .ended:
            // MARK: Pinch Ended
            pinchMove = nil
            self.views.header_footer_animation(show: true, animate: true)
            rectAdjust()
        default:
            break
        }
    }
    
    // MARK: Animation Event
    
    func moveToFront(complete: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.25, animations: {
            self.views.a.frame.origin.x = 0
            self.views.b.frame = CGRect(x: self.bounds.width + 10, y: 0, width: self.bounds.width, height: self.bounds.height)
            self.views.c.frame.origin.x = self.bounds.width * 2 + 20
        }, completion: { _ in
            self.model.index -= 1
            self.rectReset(false)
            self.loadData()
            self.views.header_footer_animation(show: true, animate: true)
            complete?()
        })
    }
    
    func moveToNext(complete: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.25, animations: {
            self.views.a.frame.origin.x = -self.bounds.width * 2 - 20
            self.views.b.frame = CGRect(x: -self.bounds.width - 10, y: 0, width: self.bounds.width, height: self.bounds.height)
            self.views.c.frame.origin.x = 0
        }, completion: { _ in
            self.model.index += 1
            self.rectReset(false)
            self.loadData()
            self.views.header_footer_animation(show: true, animate: true)
            complete?()
        })
    }
    
}

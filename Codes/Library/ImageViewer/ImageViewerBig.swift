//
//  ImageViewerBig.swift
//  ImageViewer
//
//  Created by 黄穆斌 on 2016/12/2.
//  Copyright © 2016年 Myron. All rights reserved.
//

import UIKit

// MARK: - Delegate

protocol ImageViewerBigDelegate: NSObjectProtocol {
    func imageViewerBig(image at: Int) -> UIImage?
    func imageViewerBig(forward at: Int) -> Bool
    func imageViewerBig(backward at: Int) -> Bool
    func imageViewerBig(scaling: CGFloat)
    func imageViewerBig(hidden: Bool)
}

// MARK: - View

class ImageViewerBig: UIView {

    var imagePre: UIImageView = UIImageView()
    var imageCen: UIImageView = UIImageView()
    var imageNex: UIImageView = UIImageView()
    
    var imageCenWLayout: NSLayoutConstraint!
    var imageCenHLayout: NSLayoutConstraint!
    var imageCenXLayout: NSLayoutConstraint!
    var imageCenYLayout: NSLayoutConstraint!
    
    var imagePreSpaceLayout: NSLayoutConstraint!
    var imageNexSpaceLayout: NSLayoutConstraint!
    
    var scale: CGFloat { return bounds.width / bounds.height }
    
    // MARK: - Data
    
    weak var delegate: ImageViewerBigDelegate? {
        didSet { updateImages() }
    }
    
    var index: Int = 0
    
    // MARK: - Method
    
    func relayout() {
        self.imageCenXLayout.constant = 0
        self.imageCenHLayout.constant = 0
        self.imageCenWLayout.constant = 0
        self.imageCenYLayout.constant = 0
        self.imagePreSpaceLayout.constant = -4
        self.imageNexSpaceLayout.constant = 4
    }
    
    func addGestures(view: UIView) {
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:))))
        view.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture(_:))))
    }
    
    func deleteAnimation(finish: @escaping () -> Void) {
        var x: CGFloat = 0
        if delegate?.imageViewerBig(forward: index) == false {
            x = -self.bounds.width / 2
        } else {
            index -= 1
            x = self.bounds.width / 2
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.imageCenXLayout.constant = x
            self.imageCenYLayout.constant = 0
            self.imageCenWLayout.constant = -self.bounds.width
            self.imageCenHLayout.constant = -self.bounds.width / self.scale
            self.layoutIfNeeded()
        }, completion: { _ in
            self.updateImages()
            self.relayout()
            finish()
        })
    }
    
    // MARK: - init
    
    init() {
        super.init(frame: CGRect.zero)
        initDeploy()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initDeploy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initDeploy()
    }
    
    private func initDeploy() {
        addSubview(imagePre)
        addSubview(imageCen)
        addSubview(imageNex)
        
        imagePre.contentMode = .scaleAspectFit
        imageCen.contentMode = .scaleAspectFit
        imageNex.contentMode = .scaleAspectFit
        
        layoutImages()
    }
    
    private func layoutImages() {
        Layouter(superview: self, view: imageCen).center().size().constrants(block: { (layouts) in
            self.imageCenXLayout = layouts[0]
            self.imageCenYLayout = layouts[1]
            self.imageCenWLayout = layouts[2]
            self.imageCenHLayout = layouts[3]
        })
        
        Layouter(superview: self, view: imagePre).centerY().size().setViews(relative: imageCen).layout(edge: .trailing, to: .leading, constant: -4).constrants(last: {
                self.imagePreSpaceLayout = $0
            })
        
        Layouter(superview: self, view: imageNex).centerY().size().setViews(relative: imageCen).layout(edge: .leading, to: .trailing, constant: 4).constrants(last: {
                self.imageNexSpaceLayout = $0
            })
    }
    
    // MARK: Update Image
    
    func updateImages() {
        imagePre.image = delegate?.imageViewerBig(image: index-1)
        imageCen.image = delegate?.imageViewerBig(image: index)
        imageNex.image = delegate?.imageViewerBig(image: index+1)
    }
    
    // MAKR: Gesture
    
    private var panCenter: CGPoint = CGPoint.zero
    func panGesture(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            panCenter.x = imageCenXLayout.constant
            panCenter.y = imageCenYLayout.constant
        case .changed:
            let offset = sender.translation(in: self)
            
            imageCenXLayout.constant = offset.x + panCenter.x
            if imageCenWLayout.constant > 0 {
                imageCenYLayout.constant = offset.y + panCenter.y
            }
        default:
            let velocity = sender.velocity(in: self)
            let halfWidth = imageCen.bounds.width / 2
            
            // Forward
            if (velocity.x > 1000 || imageCenXLayout.constant > halfWidth) && (delegate?.imageViewerBig(forward: index) == true) {
                UIView.animate(withDuration: 0.2, animations: {
                    self.imageCenXLayout.constant = self.bounds.width
                    self.imageCenHLayout.constant = 0
                    self.imageCenWLayout.constant = 0
                    self.imageCenYLayout.constant = 0
                    self.layoutIfNeeded()
                }, completion: { _ in
                    self.index -= 1
                    self.updateImages()
                    self.imageCenXLayout.constant = 0
                })
                return
            }
            
            // Backward
            if (velocity.x < -1000 || imageCenXLayout.constant < -halfWidth) && (delegate?.imageViewerBig(backward: index) == true) {
                UIView.animate(withDuration: 0.2, animations: {
                    self.imageCenXLayout.constant = -self.bounds.width
                    self.imageCenYLayout.constant = 0
                    self.imageCenHLayout.constant = 0
                    self.imageCenWLayout.constant = 0
                    self.layoutIfNeeded()
                }, completion: { _ in
                    self.index += 1
                    self.updateImages()
                    self.imageCenXLayout.constant = 0
                })
                return
            }
            
            // Back
            if imageCenWLayout.constant > 0 {
                UIView.animate(withDuration: 0.2, animations: {
                    if self.imageCen.frame.minX > 0 {
                        self.imageCenXLayout.constant -= self.imageCen.frame.minX
                    } else if self.imageCen.frame.maxX < self.bounds.width {
                        self.imageCenXLayout.constant += self.bounds.width - self.imageCen.frame.maxX
                    }
                    
                    if self.imageCen.frame.minY > 0 {
                        self.imageCenYLayout.constant -= self.imageCen.frame.minY
                    } else if self.imageCen.frame.maxY < self.bounds.height {
                        self.imageCenYLayout.constant += self.bounds.height - self.imageCen.frame.maxY
                    }
                    
                    self.layoutIfNeeded()
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.imageCenXLayout.constant = 0
                    self.imageCenYLayout.constant = 0
                    self.layoutIfNeeded()
                })
            }
        }
    }
    
    private var pinchSize: CGFloat = 0
    private var pinchOrigin: CGFloat = 0
    func pinchGesture(_ sender: UIPinchGestureRecognizer) {
        switch sender.state {
        case .began:
            pinchSize = imageCenWLayout.constant
            pinchOrigin = imageCen.bounds.width
        case .changed:
            imageCenWLayout.constant = pinchSize + pinchOrigin * (sender.scale - 1)
            imageCenHLayout.constant = imageCenWLayout.constant / scale
            if imageCenWLayout.constant <= 0 {
                delegate?.imageViewerBig(scaling: -imageCenWLayout.constant / bounds.width)
            }
            
            layoutIfNeeded()
            
            // Space
            if self.imageCen.frame.minX > 0 {
                self.imagePreSpaceLayout.constant = -4 - self.imageCen.frame.minX
            }
            if self.bounds.width - self.imageCen.frame.maxX > 0 {
                self.imageNexSpaceLayout.constant = 4 + self.bounds.width - self.imageCen.frame.maxX
            }
        default:
            // Big
            if imageCenWLayout.constant > bounds.width {
                let halfW = self.bounds.width / 2
                let halfH = self.bounds.height / 2
                UIView.animate(withDuration: 0.2, animations: {
                    self.imageCenWLayout.constant = self.bounds.width
                    self.imageCenHLayout.constant = self.bounds.height
                    
                    if self.imageCenXLayout.constant > halfW {
                        self.imageCenXLayout.constant = halfW
                    } else if self.imageCenXLayout.constant < -halfW {
                        self.imageCenXLayout.constant = -halfW
                    }
                    
                    if self.imageCenYLayout.constant > halfH {
                        self.imageCenYLayout.constant = halfH
                    } else if self.imageCenYLayout.constant < -halfH {
                        self.imageCenYLayout.constant = -halfH
                    }
                    
                    self.layoutIfNeeded()
                }, completion: { _ in
                    self.imagePreSpaceLayout.constant = -4
                    self.imageNexSpaceLayout.constant = 4
                })
                return
            }
            
            // Small
            if imageCenWLayout.constant <= 0 {
                if imageCenWLayout.constant < -self.bounds.width / 2 {
                    delegate?.imageViewerBig(hidden: true)
                } else {
                    delegate?.imageViewerBig(hidden: false)
                    UIView.animate(withDuration: 0.2, animations: {
                        self.imageCenXLayout.constant = 0
                        self.imageCenYLayout.constant = 0
                        self.imageCenHLayout.constant = 0
                        self.imageCenWLayout.constant = 0
                        self.layoutIfNeeded()
                    }, completion: { _ in
                        self.imagePreSpaceLayout.constant = -4
                        self.imageNexSpaceLayout.constant = 4
                    })
                }
                return
            }
            
            // Center
            UIView.animate(withDuration: 0.2, animations: {
                if self.imageCen.frame.minX > 0 {
                    self.imageCenXLayout.constant -= self.imageCen.frame.minX
                } else if self.imageCen.frame.maxX < self.bounds.width {
                    self.imageCenXLayout.constant += self.bounds.width - self.imageCen.frame.maxX
                }
                
                if self.imageCen.frame.minY > 0 {
                    self.imageCenYLayout.constant -= self.imageCen.frame.minY
                } else if self.imageCen.frame.maxY < self.bounds.height {
                    self.imageCenYLayout.constant += self.bounds.height - self.imageCen.frame.maxY
                }
                
                self.layoutIfNeeded()
            }, completion: { _ in
                self.imagePreSpaceLayout.constant = -4
                self.imageNexSpaceLayout.constant = 4
            })
        }
    }
}

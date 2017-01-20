//
//  ImageViewer2.swift
//  RangerCam2
//
//  Created by 黄穆斌 on 2017/1/4.
//  Copyright © 2017年 黄穆斌. All rights reserved.
//

import UIKit

protocol ImageViewer2Delegate: NSObjectProtocol {
    func imageViewer2(showViewer to: Bool)
}

// MARK: - Model

protocol ImageViewer2Model {
    func sectionCount() -> Int
    func rowCount(insection: Int) -> Int
    func itemImage(index: IndexPath) -> UIImage?
    func itemSelect(index: IndexPath) -> UIImage?
    
    func headerLabel(index: IndexPath) -> String?
    func headerImage(index: IndexPath) -> Int
    func headerVideo(index: IndexPath) -> Int
    func headerInterect(index: IndexPath) -> Int
    
    func changedSelect(index: IndexPath)
    
    func show(index: IndexPath)
    func itemImage(offset: Int) -> UIImage?
    func itemOffset(_ offset: Int) -> Bool
    
    func itemIndex() -> IndexPath?
}

// MARK: - ImageViewer2

class ImageViewer2: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBInspectable var showviewColor: UIColor = UIColor.white {
        didSet {
            showView.backgroundColor = showviewColor
        }
    }
    var data: ImageViewer2Model!
    var editStatus: Bool = false {
        didSet {
            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        }
    }
    var cellSize: CGSize = CGSize(width: (min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) - 20) / 4, height: (min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) - 20) / 4)
    weak var delegate: ImageViewer2Delegate?
    
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
        showImage.contentMode = UIViewContentMode.scaleAspectFill
        showImage.clipsToBounds = true
        
        showView.viewer = self
        showView.alpha = 0
        showView.isHidden = true
        addSubview(showView)
        Layouter(superview: self, view: showView).edges()
    }
    
    // MARK: - Collection
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.allowsMultipleSelection = true
        }
    }
    
    // MARK: Number
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data?.sectionCount() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data?.rowCount(insection: section) ?? 0
    }
    
    // MARK: View
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewer2CollectionCell", for: indexPath) as! ImageViewer2CollectionCell
        cell.cellImageSize = cellSize.width - 8
        cell.update(image: data?.itemImage(index: indexPath))
        cell.update(isSelectStyle: editStatus, image: data?.itemSelect(index: indexPath))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ImageViewer2CollectionHeader", for: indexPath) as! ImageViewer2CollectionHeader
            return view
        } else {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "ImageViewer2CollectionFooter", for: indexPath) as! ImageViewer2CollectionFooter
            return view
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionElementKindSectionHeader {
            let view = view as! ImageViewer2CollectionHeader
            view.update(label: data?.headerLabel(index: indexPath))
            view.update(image: data?.headerImage(index: indexPath))
        }
    }
    
    // MARK: Size
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 20)
    }
    
    // MARK: Select
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if editStatus {
            return true
        } else {
            showViewer(show: true, indexPath: indexPath)
            return false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if editStatus {
            let cell = collectionView.cellForItem(at: indexPath) as! ImageViewer2CollectionCell
            data?.changedSelect(index: indexPath)
            cell.update(isSelectStyle: true, image: data.itemSelect(index: indexPath))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if editStatus {
            let cell = collectionView.cellForItem(at: indexPath) as! ImageViewer2CollectionCell
            data?.changedSelect(index: indexPath)
            cell.update(isSelectStyle: true, image: data.itemSelect(index: indexPath))
        }
    }
    
    // MARK: - Show View
    
    var showImage: UIImageView = UIImageView()
    var showView = ImageViewer2ShowView(frame: CGRect.zero)
    var isViewer: Bool = false
    
    func showViewer(show: Bool, indexPath: IndexPath! = nil) {
        isViewer = show
        delegate?.imageViewer2(showViewer: show)
        
        if show {
            let cell = collectionView.cellForItem(at: indexPath) as! ImageViewer2CollectionCell
            data?.show(index: indexPath)
            showImage.image = cell.cellImage.image
            showImage.frame = CGRect(x: cell.frame.origin.x + 4, y: cell.frame.origin.y + 4 - collectionView.contentOffset.y, width: cell.cellImage.bounds.width, height: cell.cellImage.bounds.height)
            addSubview(showImage)
            var scale: CGFloat = 1
            if let image = showImage.image {
                scale = image.size.width / image.size.height
            }
            let height = bounds.width / scale
            let rect = CGRect(x: 0, y: (bounds.height - height) / 2, width: bounds.width, height: height)
            
            self.showView.isHidden = false
            self.showView.updateImages()
            UIView.animate(withDuration: 0.25, animations: {
                self.showImage.frame = rect
                self.showView.alpha = 1
            }, completion: { _ in
                self.showImage.removeFromSuperview()
            })
        } else {
            if let index = data.itemIndex() {
                if let cell = collectionView.cellForItem(at: index) as? ImageViewer2CollectionCell {
                    let rect = CGRect(x: cell.frame.origin.x + 4, y: cell.frame.origin.y + 4 - collectionView.contentOffset.y, width: cell.cellImage.bounds.width, height: cell.cellImage.bounds.height)
                    showImage.image = showView.images.cen.image
                    showImage.alpha = 1
                    var scale: CGFloat = 1
                    if let image = showImage.image {
                        scale = image.size.width / image.size.height
                    }
                    let height = bounds.width / scale
                    showImage.frame = CGRect(x: 0, y: (bounds.height - height) / 2, width: bounds.width, height: height)
                    addSubview(showImage)
                    UIView.animate(withDuration: 0.25, animations: { 
                        self.showImage.frame = rect
                        self.showView.alpha = 0
                    }, completion: { _ in
                        self.showImage.removeFromSuperview()
                        self.showView.isHidden = true
                    })
                    return
                }
            }
            UIView.animate(withDuration: 0.25, animations: { 
                self.showView.alpha = 0
            }, completion: { _ in
                self.showView.isHidden = true
            })
        }
        
    }
    
    // MARK: - Delete
    
    func delete(showing: Int?) {
        showView.delete(index: showing ?? 0) { 
            
        }
    }
    
    func delete(collection indexes: [IndexPath]) {
        collectionView.deleteItems(at: indexes)
    }
    
    func delete(collectionSection index: IndexSet) {
        collectionView.deleteSections(index)
    }
    
}

// MARK: - Cell

class ImageViewer2CollectionCell: UICollectionViewCell {
    
    var cellImageSize = (min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) - 20) / 4 - 8 {
        didSet {
            cellImage.mask?.frame = CGRect(x: 0, y: 0, width: cellImageSize, height: cellImageSize)
        }
    }
    
    @IBOutlet weak var cellImage: UIImageView! {
        didSet {
            cellImage.mask = UIView()
            cellImage.mask?.backgroundColor = UIColor.black
            cellImage.mask?.layer.cornerRadius = 4
            cellImage.mask?.frame = CGRect(x: 0, y: 0, width: cellImageSize, height: cellImageSize)
        }
    }
    @IBOutlet weak var selectImage: UIImageView!
    
    func update(image: UIImage?) {
        cellImage.image = image
    }
    
    func update(isSelectStyle: Bool, image: UIImage? = nil) {
        if isSelectStyle {
            selectImage.isHidden = false
            selectImage.image = image
        } else {
            selectImage.isHidden = true
        }
    }
    
}

// MARK: - Header

class ImageViewer2CollectionHeader: UICollectionReusableView {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var imageNumberLabel: UILabel!
    
    func update(label: String?) {
        headerLabel.text = label
    }
    
    func update(image: Int?) {
        imageNumberLabel.text = "\(image ?? 0)"
    }
    
}

class ImageViewer2CollectionFooter: UICollectionReusableView {
    
}

// MARK: - Big View

class ImageViewer2ShowView: UIView {
    
    weak var viewer: ImageViewer2!
    
    func delete(index: Int, completion: @escaping () -> Void) {
        if index > 0 {
            UIView.animate(withDuration: 0.25, animations: { 
                self.layouts.cen.w.constant = -self.bounds.width
                self.layouts.cen.h.constant = -self.bounds.height
                self.layouts.x.constant = -self.bounds.width - 8
                self.layouts.y.constant = 0
                self.layoutIfNeeded()
            }, completion: { _ in
                self.updateImages()
                self.layouts.cen.w.constant = 0
                self.layouts.cen.h.constant = 0
                self.layouts.x.constant = 0
                self.layouts.y.constant = 0
                completion()
            })
        } else if index == 0 {
            UIView.animate(withDuration: 0.25, animations: { 
                self.layouts.cen.w.constant = -self.bounds.width
                self.layouts.cen.h.constant = -self.bounds.height
                self.layouts.x.constant = 0
                self.layouts.y.constant = 0
                self.layoutIfNeeded()
            }, completion: { _ in
                self.updateImages()
                self.layouts.cen.w.constant = 0
                self.layouts.cen.h.constant = 0
                self.layouts.x.constant = 0
                self.layouts.y.constant = 0
                completion()
            })
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                self.layouts.cen.w.constant = -self.bounds.width
                self.layouts.cen.h.constant = -self.bounds.height
                self.layouts.x.constant = self.bounds.width + 8
                self.layouts.y.constant = 0
                self.layoutIfNeeded()
            }, completion: { _ in
                self.updateImages()
                self.layouts.cen.w.constant = 0
                self.layouts.cen.h.constant = 0
                self.layouts.x.constant = 0
                self.layouts.y.constant = 0
                completion()
            })
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
    
    func initDeploy() {
        deploy()
    }
    
    
    func deploy() {
        self.clipsToBounds = true
        self.backgroundColor = UIColor.white
        
        // Images
        images.reset(view: self)
        
        // Layouts
        Layouter(superview: self, view: images.pre).centerY().size().constrants(block: { (objects) in
            self.layouts.pre.w = objects[1]
            self.layouts.pre.h = objects[2]
        })
        Layouter(superview: self, view: images.nex).centerY().size().constrants(block: { (objects) in
            self.layouts.nex.w = objects[1]
            self.layouts.nex.h = objects[2]
        })
        Layouter(superview: self, view: images.cen).center().size().setViews(relative: images.pre).layout(edge: .leading, to: .trailing, constant: 8).setViews(relative: images.nex).layout(edge: .trailing, to: .leading, constant: -8).constrants(block: { (objects) in
            self.layouts.x = objects[0]
            self.layouts.y = objects[1]
            self.layouts.cen.w = objects[2]
            self.layouts.cen.h = objects[3]
            self.layouts.l = objects[4]
            self.layouts.r = objects[5]
        })
        
        
        // Gesture
        tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        pan = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction))
        self.addGestureRecognizer(tap)
        self.addGestureRecognizer(pan)
        self.addGestureRecognizer(pinch)
    }
    
    // MARK: Images
    
    let images = ImageViews()
    
    func updateImages() {
        images.pre.image = viewer.data.itemImage(offset: -1)
        images.cen.image = viewer.data.itemImage(offset: 0)
        images.nex.image = viewer.data.itemImage(offset: 1)
    }
    
    // MARK: Layouts
    
    let layouts = Layouts()
    
    // MARK: Gesture
    
    var tap: UITapGestureRecognizer!
    var pan: UIPanGestureRecognizer!
    var pinch: UIPinchGestureRecognizer!
    
    func tapAction(sender: UITapGestureRecognizer) {
        viewer?.showViewer(show: false)
    }
    
    var panCenter: CGPoint = CGPoint.zero
    func panAction(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            tap.isEnabled = false
            
            panCenter.x = layouts.x.constant
            panCenter.y = layouts.y.constant
        case .changed:
            let offset = sender.translation(in: self)
            let move = CGPoint(x: panCenter.x + offset.x, y: panCenter.y + offset.y)
            layouts.x.constant = move.x
            if layouts.cen.w.constant > 0 {
                layouts.y.constant = move.y
            }
        default:
            let velocity = sender.velocity(in: self)
            let halfWidth = (bounds.width + layouts.cen.w.constant) / 2
            
            // Forward
            if (velocity.x > 1000 || layouts.x.constant > halfWidth) && viewer?.data?.itemOffset(-1) == true {
                UIView.animate(withDuration: 0.25, animations: {
                    self.layouts.x.constant = self.bounds.width
                    self.layouts.y.constant = 0
                    self.layouts.cen.h.constant = 0
                    self.layouts.cen.w.constant = 0
                    self.layoutIfNeeded()
                }, completion: { _ in
                    self.updateImages()
                    self.layouts.x.constant = 0
                    self.tap.isEnabled = true
                })
                return
            }
            
            
            // Backward
            if (velocity.x < -1000 || layouts.x.constant < -halfWidth) && viewer?.data?.itemOffset(1) == true {
                UIView.animate(withDuration: 0.25, animations: {
                    self.layouts.x.constant = -self.bounds.width
                    self.layouts.y.constant = 0
                    self.layouts.cen.w.constant = 0
                    self.layouts.cen.h.constant = 0
                    self.layoutIfNeeded()
                }, completion: { _ in
                    self.updateImages()
                    self.layouts.x.constant = 0
                    self.tap.isEnabled = true
                })
                return
            }
            
            // Back
            var move = CGPoint.zero
            if layouts.cen.w.constant > 0 {
                let size = CGSize(width: layouts.cen.w.constant / 2, height: layouts.cen.h.constant / 2)
                if layouts.x.constant > 0 {
                    if size.width < layouts.x.constant {
                        move.x = size.width
                    } else {
                        move.x = layouts.x.constant
                    }
                } else {
                    if size.width < -layouts.x.constant {
                        move.x = -size.width
                    } else {
                        move.x = layouts.x.constant
                    }
                }
                if layouts.y.constant > 0 {
                    if size.height < layouts.y.constant {
                        move.y = size.height
                    } else {
                        move.y = layouts.y.constant
                    }
                } else {
                    if size.height < -layouts.y.constant {
                        move.y = -size.height
                    } else {
                        move.y = layouts.y.constant
                    }
                }
            }
            UIView.animate(withDuration: 0.25, animations: {
                self.layouts.x.constant = move.x
                self.layouts.y.constant = move.y
                self.layoutIfNeeded()
            }, completion: { _ in
                self.tap.isEnabled = true
            })
        }
    }
    
    private var pinchConstant: CGFloat = 0
    private var pinchWidth: CGFloat = 0
    func pinchAction(sender: UIPinchGestureRecognizer) {
        switch sender.state {
        case .began:
            self.tap.isEnabled = false
            
            layouts.l.constant = 1000
            layouts.r.constant = -1000
            
            pinchConstant = layouts.cen.w.constant
            pinchWidth = bounds.width + pinchConstant
        case .changed:
            layouts.cen.w.constant = pinchConstant + pinchWidth * (sender.scale - 1)
            layouts.cen.h.constant = layouts.cen.w.constant / (bounds.width / bounds.height)
        default:
            // Big
            if layouts.cen.w.constant > bounds.width {
                let size = CGSize(width: self.bounds.width / 2, height: self.bounds.height / 2)
                var move = CGPoint.zero
                if layouts.x.constant > 0 {
                    if size.width < layouts.x.constant {
                        move.x = size.width
                    } else {
                        move.x = layouts.x.constant
                    }
                } else {
                    if size.width < -layouts.x.constant {
                        move.x = -size.width
                    } else {
                        move.x = layouts.x.constant
                    }
                }
                if layouts.y.constant > 0 {
                    if size.height < layouts.y.constant {
                        move.y = size.height
                    } else {
                        move.y = layouts.y.constant
                    }
                } else {
                    if size.height < -layouts.y.constant {
                        move.y = -size.height
                    } else {
                        move.y = layouts.y.constant
                    }
                }
                UIView.animate(withDuration: 0.25, animations: { 
                    self.layouts.x.constant = move.x
                    self.layouts.y.constant = move.y
                    self.layouts.cen.w.constant = size.width * 2
                    self.layouts.cen.h.constant = size.height * 2
                    self.layouts.l.constant = 8
                    self.layouts.r.constant = -8
                    self.layoutIfNeeded()
                }, completion: { _ in
                    self.tap.isEnabled = true
                })
                return
            }
            
            // Small
            if layouts.cen.w.constant < 0 {
                UIView.animate(withDuration: 0.25, animations: { 
                    self.layouts.x.constant = 0
                    self.layouts.y.constant = 0
                    self.layouts.cen.w.constant = 0
                    self.layouts.cen.h.constant = 0
                    self.layouts.l.constant = 8
                    self.layouts.r.constant = -8
                    self.layoutIfNeeded()
                }, completion: { _ in
                    self.tap.isEnabled = true
                })
                return
            }
            
            
            self.tap.isEnabled = true
        }
    }
    
}


// MAKR: - Big View Layout

extension ImageViewer2ShowView {
    
    class ImageViews {
        var pre = UIImageView()
        var cen = UIImageView()
        var nex = UIImageView()
        
        func reset(view: UIView) {
            for image in [cen, pre, nex] {
                image.contentMode = UIViewContentMode.scaleAspectFit
                view.addSubview(image)
                image.isUserInteractionEnabled = false
            }
//            
//            pre.image = UIImage(named: "01")
//            cen.image = UIImage(named: "02")
//            nex.image = UIImage(named: "03")
        }
    }
    
    class Layout {
        var w: NSLayoutConstraint!
        var h: NSLayoutConstraint!
    }
    
    class Layouts {
        var x: NSLayoutConstraint!
        var y: NSLayoutConstraint!
        var l: NSLayoutConstraint!
        var r: NSLayoutConstraint!
        
        var pre = Layout()
        var cen = Layout()
        var nex = Layout()
    }
    
}

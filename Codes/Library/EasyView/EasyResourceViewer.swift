//
//  EasyResourceViewer.swift
//  EasyViewer
//
//  Created by 黄穆斌 on 2017/3/2.
//  Copyright © 2017年 MubinHuang. All rights reserved.
//

import UIKit

// MARK: - Protocol


protocol EasyResourceNormalProtocol: EasyResourceCollectionCellProtocol, EasyResourceCollectionHeaderProtocol, EasyResourceViewerProtocol {
}

protocol EasyResourceProtocol: EasyResourceCollectionCellProtocol, EasyResourceCollectionHeaderProtocol, EasyResourceCollectionFooterProtocol, EasyResourceViewerProtocol {
    
}

protocol EasyResourceCollectionCellProtocol: NSObjectProtocol {
    var itemSize: CGSize { get }
    func numberOfSection() -> Int
    func numberOfItem(inSection section: Int) -> Int
    func cellData(index: IndexPath) -> Any?
    
    func loadCell(index: IndexPath, cell: EasyResourceCollectionCell)
    func updateCell(index: IndexPath, cell: EasyResourceCollectionCell)
    func selectCell(index: IndexPath, cell: EasyResourceCollectionCell) -> Bool
    func resizeCell(index: IndexPath, cell: EasyResourceCollectionCell)
}

protocol EasyResourceCollectionHeaderProtocol: NSObjectProtocol {
    var headerSize: CGSize { get }
    func headerData(index: IndexPath) -> Any?
    
    func loadHeader(index: Int, cell: EasyResourceCollectionHeader)
    func updateHeader(index: Int, cell: EasyResourceCollectionHeader)
    func resizeHeader(index: Int, cell: EasyResourceCollectionHeader)
}

protocol EasyResourceCollectionFooterProtocol: NSObjectProtocol {
    var footerSize: CGSize { get }
    func footerData(index: IndexPath) -> Any?
    
    func loadFooter(index: Int, cell: EasyResourceCollectionFooter)
    func updateFooter(index: Int, cell: EasyResourceCollectionFooter)
    func resizeFooter(index: Int, cell: EasyResourceCollectionFooter)
}

@objc protocol EasyResourceViewerProtocol: NSObjectProtocol {
    
    func viewerBackEvent(row: Int, section: Int)
    func viewerDeleteEvent(row: Int, section: Int)
    
    func viewerMoveToFront(row: Int, section: Int) -> Bool
    func viewerMoveToNext(row: Int, section: Int) -> Bool
    
    func viewerData(row: Int, section: Int) -> Any?
    
    func loadSubViewer(row: Int, section: Int, cell: EasyResourceViewerCell)
    func updateSubViewer(row: Int, section: Int, cell: EasyResourceViewerCell)
    func resizeSubViewer(row: Int, section: Int, cell: EasyResourceViewerCell)
    
    @objc optional func loadHeaderViewer(row: Int, section: Int, cell: EasyResourceViewerCell)
    @objc optional func updateHeaderViewer(row: Int, section: Int, cell: EasyResourceViewerCell)
    @objc optional func resizeHeaderViewer(row: Int, section: Int, cell: EasyResourceViewerCell)
    
    @objc optional func loadFooterViewer(row: Int, section: Int, cell: EasyResourceViewerCell)
    @objc optional func updateFooterViewer(row: Int, section: Int, cell: EasyResourceViewerCell)
    @objc optional func resizeFooterViewer(row: Int, section: Int, cell: EasyResourceViewerCell)
}


// MARK: - Models

class EasyResourceCollectionModel: EasyCollectionModel {
    weak var resource: EasyResourceViewer!
    
    override var cellType: AnyClass? { return EasyResourceCollectionCell.self }
    override var itemSize: CGSize {
        return resource.collectionCellDelegate?.itemSize ?? CGSize.zero
    }
    
    override var headerType: AnyClass? { return EasyResourceCollectionHeader.self }
    override var headerSize: CGSize {
        return resource.collectionHeaderDelegate?.headerSize ?? CGSize.zero
    }
    
    override var footerType: AnyClass? { return EasyResourceCollectionFooter.self }
    override var footerSize: CGSize {
        return resource.collectionFooterDelegate?.footerSize ?? CGSize.zero
    }
    
    override var numberOfSection: Int {
        return resource.collectionCellDelegate?.numberOfSection() ?? 0
    }
    override func numberOfItem(inSection section: Int) -> Int {
        return resource.collectionCellDelegate?.numberOfItem(inSection: section) ?? 0
    }
    
    override func headerData(index: IndexPath) -> Any? {
        return resource.collectionHeaderDelegate?.headerData(index: index)
    }
    override func footerData(index: IndexPath) -> Any? {
        return resource.collectionFooterDelegate?.footerData(index: index)
    }
    override func cellData(index: IndexPath) -> Any? {
        return resource.collectionCellDelegate?.cellData(index: index)
    }
    
    override func cellEventObject(index: IndexPath) -> AnyObject? {
        return resource
    }
    override func headerEventObject(index: IndexPath) -> AnyObject? {
        return resource
    }
    override func footerEventObject(index: IndexPath) -> AnyObject? {
        return resource
    }
}

class EasyResourceViewerModel: EasyViewerModel {
    weak var resource: EasyResourceViewer!
    
    override func backEvent(index: Int) {
        resource.viewerDelegate?.viewerBackEvent(row: index, section: resource.dataSection)
        resource.hidden(viewer: index)
    }
    
    override func deleteEvent(index: Int) {
        resource.viewerDelegate?.viewerDeleteEvent(row: index, section: resource.dataSection)
    }
    
    override func moveBack(index: Int) -> CGRect {
        return resource.willHidden(viewer: index)
    }
    
    override func moveToFront(index: Int) -> Bool {
        return resource.viewerDelegate?.viewerMoveToFront(row: index, section: resource.dataSection) ?? false
    }
    
    override func moveToNext(index: Int) -> Bool {
        return resource.viewerDelegate?.viewerMoveToNext(row: index, section: resource.dataSection) ?? false
    }
    
    // MARK: Datas
    
    override func viewData(index: Int) -> Any? {
        return resource.viewerDelegate?.viewerData(row: index, section: resource.dataSection)
    }
    override func viewEventObject(index: Int) -> AnyObject? {
        return resource
    }
}

// MARK: - Views

class EasyResourceCollectionCell: EasyCollectionCell {
    
    var resource: EasyResourceViewer? {
        return eventObjcet as? EasyResourceViewer
    }
    override func loadView() {
        resource?.collectionCellDelegate?.loadCell(index: index, cell: self)
    }
    override func update() {
        resource?.collectionCellDelegate?.updateCell(index: index, cell: self)
    }
    override func selectView() {
        if resource?.collectionCellDelegate?.selectCell(index: index, cell: self) == true {
            resource?.show(viewer: self.frame, row: index.row, section: index.section)
        }
    }
    override func resize() {
        resource?.collectionCellDelegate?.resizeCell(index: index, cell: self)
    }
    
}
class EasyResourceCollectionHeader: EasyCollectionHeader {
    
    var resource: EasyResourceViewer? {
        return eventObjcet as? EasyResourceViewer
    }
    override func loadView() {
        resource?.collectionHeaderDelegate?.loadHeader(index: index, cell: self)
    }
    override func update() {
        resource?.collectionHeaderDelegate?.updateHeader(index: index, cell: self)
    }
    override func resize() {
        resource?.collectionHeaderDelegate?.resizeHeader(index: index, cell: self)
    }
    
}
class EasyResourceCollectionFooter: EasyCollectionFooter {
    
    var resource: EasyResourceViewer? {
        return eventObjcet as? EasyResourceViewer
    }
    override func loadView() {
        resource?.collectionFooterDelegate?.loadFooter(index: index, cell: self)
    }
    override func update() {
        resource?.collectionFooterDelegate?.updateFooter(index: index, cell: self)
    }
    override func resize() {
        resource?.collectionFooterDelegate?.resizeFooter(index: index, cell: self)
    }
    
}

class EasyResourceViewerCell: EasyViewerSubView {
    
    var resource: EasyResourceViewer? {
        return eventObject as? EasyResourceViewer
    }
    override func loadView() {
        switch type {
        case .view:
            resource?.viewerDelegate?.loadSubViewer(row: index, section: resource?.dataSection ?? 0, cell: self)
        case .header:
            resource?.viewerDelegate?.loadHeaderViewer?(row: index, section: resource?.dataSection ?? 0, cell: self)
        case .footer:
            resource?.viewerDelegate?.loadFooterViewer?(row: index, section: resource?.dataSection ?? 0, cell: self)
        }
    }
    override func update() {
        switch type {
        case .view:
            resource?.viewerDelegate?.updateSubViewer(row: index, section: resource?.dataSection ?? 0, cell: self)
        case .header:
            resource?.viewerDelegate?.updateHeaderViewer?(row: index, section: resource?.dataSection ?? 0, cell: self)
        case .footer:
            resource?.viewerDelegate?.updateFooterViewer?(row: index, section: resource?.dataSection ?? 0, cell: self)
        }
    }
    override func resize() {
        switch type {
        case .view:
            resource?.viewerDelegate?.resizeSubViewer(row: index, section: resource?.dataSection ?? 0, cell: self)
        case .header:
            resource?.viewerDelegate?.resizeHeaderViewer?(row: index, section: resource?.dataSection ?? 0, cell: self)
        case .footer:
            resource?.viewerDelegate?.resizeFooterViewer?(row: index, section: resource?.dataSection ?? 0, cell: self)
        }
    }
    
}

// MARK: - Easy Resource Viewer

class EasyResourceViewer: UIView {
    
    // MARK: - Delegate
    
    weak var collectionCellDelegate: EasyResourceCollectionCellProtocol?
    weak var collectionHeaderDelegate: EasyResourceCollectionHeaderProtocol?
    weak var collectionFooterDelegate: EasyResourceCollectionFooterProtocol?
    weak var viewerDelegate: EasyResourceViewerProtocol?
    
    // MARK: - Value
    
    var dataSection: Int = 0
    override var backgroundColor: UIColor? {
        didSet {
            collection.backgroundColor = backgroundColor
        }
    }
    
    func updateData(section: Int, row: Int) {
        if let cell = collection.cellForItem(at: IndexPath(row: row, section: section)) as? EasyCollectionCell {
            cell.update()
        }
        if viewer.isHidden == false {
            if section == dataSection && row == viewer.model.index {
                viewer.views.b.update()
            }
        }
    }
    
    // MARK: - Deploy
    
    func deploy() {
        self.clipsToBounds = true
        
        collection.frame = bounds
        collection.layout.minimumLineSpacing = 4
        collection.layout.minimumInteritemSpacing = 4
        let model = EasyResourceCollectionModel()
        model.resource = self
        collection.model = model
        addSubview(collection)
        
        viewer.frame = bounds
        viewer.views.a = EasyResourceViewerCell()
        viewer.views.b = EasyResourceViewerCell()
        viewer.views.c = EasyResourceViewerCell()
        viewer.views.header = EasyResourceViewerCell(type: .header)
        viewer.views.footer = EasyResourceViewerCell(type: .footer)
        viewer.isHidden = true
        let model2 = EasyResourceViewerModel()
        model2.resource = self
        viewer.model = model2
        addSubview(viewer)
        
        collection.deploy()
        viewer.deploy()
    }
    
    deinit {
        print("Easy Resource View deinit")
    }
    
    // MARK: - Collection
    
    var collection = EasyCollection()
    
    // MARK: - Viewer
    
    var viewer = EasyViewer()
    
    func show(viewer rect: CGRect, row: Int, section: Int) {
        let openRect = CGRect(x: rect.minX - collection.contentOffset.x, y: rect.minY - collection.contentOffset.y, width: rect.width, height: rect.height)
        dataSection = section
        viewer.model.index = row
        viewer.loadData()
        viewer.views.b.frame = openRect
        viewer.backgroundView.alpha = 0
        viewer.isHidden = false
        UIView.animate(withDuration: 0.25, animations: { 
            self.viewer.views.b.frame = self.viewer.bounds
        }, completion: { _ in
            self.viewer.backgroundView.alpha = 1
        })
    }
    
    func willHidden(viewer index: Int) -> CGRect {
        if let cell = collection.cellForItem(at: IndexPath(row: index, section: dataSection)) {
            return cell.frame
        } else if let indexPath = collection.indexPathsForVisibleItems.first {
            if indexPath.section > dataSection {
                return CGRect(x: bounds.width / 2, y: -100, width: 0, height: 0)
            } else {
                return CGRect(x: bounds.width / 2, y: bounds.height + 100, width: 0, height: 0)
            }
        }
        return CGRect.zero
    }
    
    func hidden(viewer index: Int) {
        viewer.isHidden = true
    }
    
    // MARK: - Size
    
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
    
    func resize() {
        collection.frame = bounds
        viewer.frame = bounds
    }
    
}

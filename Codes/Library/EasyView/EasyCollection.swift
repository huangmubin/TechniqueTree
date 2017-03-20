//
//  EasyCollection.swift
//  EasyViewer
//
//  Created by 黄穆斌 on 2017/2/28.
//  Copyright © 2017年 MubinHuang. All rights reserved.
//

import UIKit

// MARK: - Cell

class EasyCollectionCell: UICollectionViewCell {
    weak var eventObjcet: AnyObject?
    
    var _deploy = true
    var index: IndexPath!
    var data: Any?
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
    func selectView() {
        
    }
    func resize() {
        
    }
    
    // MARK: Size
    
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

// MARK: - Header Footer

class EasyCollectionHeader: UICollectionReusableView {
    weak var eventObjcet: AnyObject?
    
    var _deploy = true
    var index: Int!
    var data: Any?
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
    
    // MARK: Size
    
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

class EasyCollectionFooter: UICollectionReusableView {
    weak var eventObjcet: AnyObject?
    
    var _deploy = true
    var index: Int!
    var data: Any?
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
    
    // MARK: Size
    
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

// MARK: - Model

protocol EasyCollectionModelProtocol {
    
    var cellIdentifier: String { get }
    var cellType: AnyClass? { get }
    var itemSize: CGSize { get }
    
    var headerIdentifier: String { get }
    var headerType: AnyClass? { get }
    var headerSize: CGSize { get }
    
    var footerIdentifier: String { get }
    var footerType: AnyClass? { get }
    var footerSize: CGSize { get }
    
    var numberOfSection: Int { get }
    func numberOfItem(inSection section: Int) -> Int
    
    func headerData(index: IndexPath) -> Any?
    func footerData(index: IndexPath) -> Any?
    func cellData(index: IndexPath) -> Any?
    
    func cellEventObject(index: IndexPath) -> AnyObject?
    func headerEventObject(index: IndexPath) -> AnyObject?
    func footerEventObject(index: IndexPath) -> AnyObject?
    
}

class EasyCollectionModel: EasyCollectionModelProtocol {
    
    var cellIdentifier: String { return "EasyCollectionCell_Default" }
    var cellType: AnyClass? { return EasyCollectionCell.self }
    var itemSize: CGSize { return CGSize(width: 100, height: 100) }
    
    var headerIdentifier: String { return "EasyCollectionHeader_Default" }
    var headerType: AnyClass? { return EasyCollectionHeader.self }
    var headerSize: CGSize { return CGSize(width: 0, height: 0) }
    
    var footerIdentifier: String { return "EasyCollectionFooter_Default" }
    var footerType: AnyClass? { return EasyCollectionFooter.self }
    var footerSize: CGSize { return CGSize(width: 0, height: 0) }
    
    var numberOfSection: Int { return 1 }
    func numberOfItem(inSection section: Int) -> Int {
        return 0
    }
    
    func headerData(index: IndexPath) -> Any? {
        return nil
    }
    func footerData(index: IndexPath) -> Any? {
        return nil
    }
    func cellData(index: IndexPath) -> Any? {
        return nil
    }
    
    func cellEventObject(index: IndexPath) -> AnyObject? {
        return nil
    }
    func headerEventObject(index: IndexPath) -> AnyObject? {
        return nil
    }
    func footerEventObject(index: IndexPath) -> AnyObject? {
        return nil
    }
    
}

// MARK: - Collection

class EasyCollection: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    deinit {
        print("EasyCollection deinit")
    }
    // MARK: Value
    
    var layout = UICollectionViewFlowLayout()
    var model: EasyCollectionModelProtocol = EasyCollectionModel()
    
    // MARK: Init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(frame: UIScreen.main.bounds, collectionViewLayout: layout)
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    init() {
        super.init(frame: UIScreen.main.bounds, collectionViewLayout: layout)
    }
    
    func deploy() {
        self.delegate = self
        self.dataSource = self
        
        self.register(model.cellType, forCellWithReuseIdentifier: model.cellIdentifier)
        self.register(model.headerType, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: model.headerIdentifier)
        self.register(model.footerType, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: model.footerIdentifier)
        
        self.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return model.numberOfSection
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.numberOfItem(inSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: model.cellIdentifier, for: indexPath) as! EasyCollectionCell
        cell.index = indexPath
        cell.data = model.cellData(index: indexPath)
        cell.eventObjcet = model.cellEventObject(index: indexPath)
        cell.deploy()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: model.headerIdentifier, for: indexPath) as! EasyCollectionHeader
            view.index = indexPath.section
            view.data = model.headerData(index: indexPath)
            view.eventObjcet = model.headerEventObject(index: indexPath)
            view.deploy()
            return view
        } else {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: model.footerIdentifier, for: indexPath) as! EasyCollectionFooter
            view.index = indexPath.section
            view.data = model.footerData(index: indexPath)
            view.eventObjcet = model.footerEventObject(index: indexPath)
            view.deploy()
            return view
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! EasyCollectionCell
        cell.update()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionElementKindSectionHeader {
            let view = view as! EasyCollectionHeader
            view.update()
        } else {
            let view = view as! EasyCollectionFooter
            view.update()
        }
    }
    
    // MARK: Size
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return model.headerSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return model.footerSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return model.itemSize
    }
    
    // MARK: Select
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? EasyCollectionCell {
            cell.selectView()
        }
    }
    
}

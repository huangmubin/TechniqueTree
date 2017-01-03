//
//  ImageViewerCollection.swift
//  ImageViewer
//
//  Created by 黄穆斌 on 2016/12/2.
//  Copyright © 2016年 Myron. All rights reserved.
//

import UIKit

// MARK: - Delegate

@objc protocol ImageViewerCollectionDelegate: NSObjectProtocol {
    func imageViewerCollection(numberOfSection collection: ImageViewerCollection) -> Int
    func imageViewerCollection(numberOfItem inSection: Int) -> Int
    func imageViewerCollection(cell: ImageViewerCollectionCell, at index: IndexPath)
    func imageViewerCollection(header: ImageViewerCollectionHeader, at index: Int)
    
    @objc optional func imageViewerCollection(sizeOfCell at: IndexPath) -> CGSize
    @objc optional func imageViewerCollection(sizeOfHeader at: Int) -> CGSize
    
    func imageViewerCollection(select cell: ImageViewerCollectionCell, at: IndexPath)
}

// MARK: - View

class ImageViewerCollection: UIView {

    var layout = UICollectionViewFlowLayout()
    var collection: UICollectionView!
    var headerSize = CGSize(width: UIScreen.main.bounds.width, height: 40)
    var itemSize = CGSize(width: (UIScreen.main.bounds.width - 12) / 4, height: (UIScreen.main.bounds.width - 12) / 64 * 9)
    
    // MARK: - Data
    
    weak var delegate: ImageViewerCollectionDelegate?
    
    // MARK: - Method
    
    func reload() {
        collection.reloadData()
    }
    
    func visibleCellsForEach(body: (ImageViewerCollectionCell) -> Void) {
        collection.visibleCells.forEach { (cell) in
            body(cell as! ImageViewerCollectionCell)
        }
    }
    
    func visibleCellsAndIndexForEach(body: (ImageViewerCollectionCell, IndexPath) -> Void) {
        let cells = collection.visibleCells as! [ImageViewerCollectionCell]
        let index = collection.indexPathsForVisibleItems
        for i in 0 ..< cells.count {
            body(cells[i], index[i])
        }
    }
    
    // MAKR: - Init
    
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
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        
        collection = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: layout)
        collection.backgroundColor = UIColor.clear
        collection.register(ImageViewerCollectionCell.self, forCellWithReuseIdentifier: "ImageViewerCollectionCell")
        collection.register(ImageViewerCollectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ImageViewerCollectionHeader")
        collection.dataSource = self
        collection.delegate = self
        
        addSubview(collection)
        Layouter(superview: self, view: collection).edges()
    }
    
}


extension ImageViewerCollection: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return delegate?.imageViewerCollection(numberOfSection: self) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate?.imageViewerCollection(numberOfItem: section) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewerCollectionCell", for: indexPath) as! ImageViewerCollectionCell
        delegate?.imageViewerCollection(cell: cell, at: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        delegate?.imageViewerCollection(cell: cell as! ImageViewerCollectionCell, at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ImageViewerCollectionHeader", for: indexPath) as! ImageViewerCollectionHeader
        delegate?.imageViewerCollection(header: view, at: indexPath.section)
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        delegate?.imageViewerCollection(header: view as! ImageViewerCollectionHeader, at: indexPath.section)
    }
    
}

extension ImageViewerCollection: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return delegate?.imageViewerCollection?(sizeOfCell: indexPath) ?? itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return delegate?.imageViewerCollection?(sizeOfHeader: section) ?? headerSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ImageViewerCollectionCell {
            delegate?.imageViewerCollection(select: cell, at: indexPath)
        }
    }
    
}

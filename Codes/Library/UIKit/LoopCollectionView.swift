//
//  LoopCollectionView.swift
//  Calendar
//
//  Created by 黄穆斌 on 2016/11/14.
//  Copyright © 2016年 Myron. All rights reserved.
//

import UIKit

// MARK: - Loop CollectionView Delegate

@objc protocol LoopCollectionViewDelegate: NSObjectProtocol {
    
    // MARK: Request
    func loopCollection(loopView: LoopCollectionView, numberOfItemsInSection section: Int) -> Int
    func loopCollection(loopView: LoopCollectionView, cellForItem cell: LoopCollectionViewCell, atSection section: Int, row: Int)
    func loopCollection(loopView: LoopCollectionView, headerForItem header: UICollectionReusableView, atSection section: Int)
    
    // MARK: Visible
    @objc optional func loopCollection(loopView: LoopCollectionView, layout: UICollectionViewLayout, sizeForHeaderInSection section: Int) -> CGSize
    @objc optional func loopCollection(loopView: LoopCollectionView, layout: UICollectionViewLayout, sizeForItemAtSection section: Int, row: Int) -> CGSize
    @objc optional func loopCollection(loopView: LoopCollectionView, willDisplay cell: LoopCollectionViewCell, atSection section: Int, row: Int)
    @objc optional func loopCollection(loopView: LoopCollectionView, willDisplayHeader header: UICollectionReusableView, atSection section: Int)
    
    // MARK: Select
    @objc optional func loopCollection(loopView: LoopCollectionView, didSelectItemAt section: Int, row: Int)
}

// MARK: - Loop Collection View Cell

class LoopCollectionViewCell: UICollectionViewCell {
    
    var section: Int = 0
    var row: Int = 0
    weak var collection: LoopCollectionView?
    @IBOutlet weak var label: UILabel!
    
}

// MARK: - Loop CollectionView

class LoopCollectionView: UICollectionView {

    // MARK: - Init
    
    func initDeploy(delegate: LoopCollectionViewDelegate) {
        self.dataSource = self
        self.delegate   = self
        self.loopDelegate = delegate
        self.reloadData()
        self.scrollToOffset()
    }
    
    func scrollToOffset(offset: Int = 0, animated: Bool = false) {
        DispatchQueue.main.async {
            let index = IndexPath(item: 0, section: self.origin + offset)
            self.scrollToItem(at: index, at: .top, animated: animated)
            self.scrollToItem(at: index, at: .left, animated: animated)
        }
    }
    
    // MARK: - Collection View Property
    
    @IBInspectable var cellIdentifier: String = "LoopCollectionViewCell"
    @IBInspectable var headerIdentifier: String = "headerIdentifier"
    
    @IBInspectable var cellSize: CGSize = CGSize.zero
    @IBInspectable var headerSize: CGSize = CGSize.zero
    
    // MARK: - Loop Collection View Delegate
    
    weak var loopDelegate: LoopCollectionViewDelegate?
    
    @IBInspectable var origin: Int = 5000
    
}

// MARK: - Count Property

extension LoopCollectionView {
    
    var visibleItems: [LoopCollectionViewCell] {
        let cells = self.visibleCells.sorted(by: {
             ($0 as! LoopCollectionViewCell).section < ($1 as! LoopCollectionViewCell).section
        })
        let range = (self.contentOffset.x - 5, self.contentOffset.y - 5, self.contentOffset.x + self.bounds.width - 5, self.contentOffset.y + self.bounds.height - 5)
        return cells.flatMap({
            if $0.frame.origin.x > range.0 &&
               $0.frame.origin.y > range.1 &&
               $0.frame.origin.x < range.2 &&
               $0.frame.origin.y < range.3 {
               return $0 as? LoopCollectionViewCell
            }
            return nil
        })
    }
    
}

// MARK: - Update

extension LoopCollectionView {
    
    func reloadVisibleItems() {
        self.reloadItems(at: self.indexPathsForVisibleItems)
    }
    
}

// MARK: - UICollectionViewDataSource

extension LoopCollectionView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return origin * 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loopDelegate?.loopCollection(loopView: self, numberOfItemsInSection: section - origin) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! LoopCollectionViewCell
        cell.section = indexPath.section - origin
        cell.row = indexPath.row
        cell.collection = self
        loopDelegate?.loopCollection(loopView: self, cellForItem: cell, atSection: indexPath.section - origin, row: indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let item = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath)
        loopDelegate?.loopCollection(loopView: self, headerForItem: item, atSection: indexPath.section - origin)
        return item
    }
    
}

// MARK: - UICollectionViewDelegate

extension LoopCollectionView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        loopDelegate?.loopCollection?(loopView: self, willDisplay: cell as! LoopCollectionViewCell, atSection: indexPath.section - origin, row: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionElementKindSectionHeader {
            loopDelegate?.loopCollection?(loopView: self, willDisplayHeader: view, atSection: indexPath.section - origin)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        loopDelegate?.loopCollection?(loopView: self, didSelectItemAt: indexPath.section - origin, row: indexPath.row)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension LoopCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return loopDelegate?.loopCollection?(loopView: self, layout: collectionViewLayout, sizeForItemAtSection: indexPath.section - origin, row: indexPath.row) ?? cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return loopDelegate?.loopCollection?(loopView: self, layout: collectionViewLayout, sizeForHeaderInSection: section - origin) ?? headerSize
    }
    
}

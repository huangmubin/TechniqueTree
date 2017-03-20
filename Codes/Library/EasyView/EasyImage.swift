//
//  EasyImage.swift
//  EasyViewer
//
//  Created by 黄穆斌 on 2017/3/2.
//  Copyright © 2017年 MubinHuang. All rights reserved.
//

import UIKit

protocol EasyImageDataSource: NSObjectProtocol {
    func easyImageInSection() -> Int
    func easyImageSections() -> Int
    func easyImageRows(inSection section: Int) -> Int
    func easyImage(row: Int, section: Int) -> UIImage?
}

class EasyImageModel: NSObject, EasyResourceCollectionCellProtocol, EasyResourceViewerProtocol {
    
    weak var data: EasyImageDataSource!
    
    // MARK: - EasyResourceCollectionCellProtocol
    
    var itemSize: CGSize {
        let s = (UIScreen.main.bounds.width - 12) / 4
        return CGSize(width: s, height: s)
    }
    func numberOfSection() -> Int {
        return data?.easyImageSections() ?? 0
    }
    func numberOfItem(inSection section: Int) -> Int {
        return data.easyImageRows(inSection: section)
    }
    func cellData(index: IndexPath) -> Any? {
        return data.easyImage(row: index.row, section: index.section)
    }
    
    func loadCell(index: IndexPath, cell: EasyResourceCollectionCell) {
        let image = UIImageView()
        image.tag = 10
        image.contentMode = .scaleAspectFill
        cell.addSubview(image)
        image.frame = cell.bounds
        cell.clipsToBounds = true
    }
    func updateCell(index: IndexPath, cell: EasyResourceCollectionCell) {
        let image = cell.viewWithTag(10) as? UIImageView
        image?.image = cell.data as? UIImage
    }
    func selectCell(index: IndexPath, cell: EasyResourceCollectionCell) -> Bool {
        return true
    }
    func resizeCell(index: IndexPath, cell: EasyResourceCollectionCell) {
        let image = cell.viewWithTag(10) as? UIImageView
        image?.frame = cell.bounds
    }
    
    // MARK: - EasyResourceViewerProtocol
    
    func viewerBackEvent(row: Int, section: Int) {
        
    }
    func viewerDeleteEvent(row: Int, section: Int) {
        
    }
    
    func viewerMoveToFront(row: Int, section: Int) -> Bool {
        let i = data.easyImageInSection()
        if i > 0 && data.easyImageRows(inSection: i) > 0 {
            return true
        } else {
            return false
        }
    }
    func viewerMoveToNext(row: Int, section: Int) -> Bool {
        let i = data.easyImageInSection()
        return i >= 0 && i < data.easyImageRows(inSection: i) - 2
    }
    
    func viewerData(row: Int, section: Int) -> Any? {
        return data.easyImage(row: row, section: section)
    }
    
    func loadSubViewer(row: Int, section: Int, cell: EasyResourceViewerCell) {
        let image = UIImageView()
        image.tag = 10
        image.contentMode = .scaleAspectFit
        cell.addSubview(image)
        image.frame = cell.bounds
    }
    func updateSubViewer(row: Int, section: Int, cell: EasyResourceViewerCell) {
        let image = cell.viewWithTag(10) as? UIImageView
        image?.image = cell.data as? UIImage
    }
    func resizeSubViewer(row: Int, section: Int, cell: EasyResourceViewerCell) {
        let image = cell.viewWithTag(10) as? UIImageView
        image?.frame = cell.bounds
    }

}

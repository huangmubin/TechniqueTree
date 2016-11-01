//
//  TableView.swift
//  iOSTestProject
//
//  Created by 黄穆斌 on 16/11/1.
//  Copyright © 2016年 MuBinHuang. All rights reserved.
//

import UIKit

// MARK: - Protocol


protocol ResourceDataModelProtocol {
    
}

protocol CellViewProtocol {
    func cellViewDeploy(data: ResourceDataModelProtocol)
    func cellViewReset(data: ResourceDataModelProtocol)
}

// MARK: - TableView

class TableView: UITableView {

    @IBInspectable var identify: String = ""
    var datas: [[ResourceDataModelProtocol]] = [[]]
    
    // MARK: Init
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.dataSource = self
    }
    
}

extension TableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identify, for: indexPath)
        (cell as? CellViewProtocol)?.cellViewDeploy(data: datas[indexPath.section][indexPath.row])
        return cell
    }
    
}

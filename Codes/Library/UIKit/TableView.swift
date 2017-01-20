//
//  TableView.swift
//  iOSTestProject
//
//  Created by 黄穆斌 on 16/11/1.
//  Copyright © 2016年 MuBinHuang. All rights reserved.
//

import UIKit

// MARK: - Status

enum TableViewRefreshViewStatus {
    case draging(CGFloat)
    case willRefresh
    case refreshing(CGFloat)
    case finished(Bool, String?)
}

enum TableViewRefreshStatus {
    case normal
    case header(TableViewRefreshViewStatus)
    case footer(TableViewRefreshViewStatus)
}

// MARK: - Table View Refresh Protocol

protocol TableViewRefreshProtocol: NSObjectProtocol {
    var viewHeight: CGFloat { get set }
    func update(status: TableViewRefreshViewStatus)
    func reset()
}

protocol TableViewRefreshDelegate: NSObjectProtocol {
    func tableView(headerRefresh finish: @escaping (Bool, String?) -> Void)
    func tableView(footerRefresh finish: @escaping (Bool, String?) -> Void)
}

// MARK: - TableView

class TableView: UITableView {
    
    // MARK: - Data
    
    @IBOutlet weak var refreshController: UIViewController! {
        didSet {
            refreshDelegate = refreshController as? TableViewRefreshDelegate
        }
    }
    weak var refreshDelegate: TableViewRefreshDelegate?
    
    // MAKR: Remove Refresh
    
    @IBInspectable var removeHeader: Bool = false {
        didSet {
            if removeHeader {
                headerView = nil
            }
        }
    }
    @IBInspectable var removeFooter: Bool = false {
        didSet {
            if removeFooter {
                headerView = nil
            }
        }
    }
    
    // MARK: - init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initDeploy()
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        initDeploy()
    }
    
    private func initDeploy() {
        self.delegate = self
        
        if headerView == nil && !removeHeader {
            let header = TableViewRefresh(frame: CGRect.zero)
            //header.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            headerView = header
        }
        
        if footerView == nil && !removeFooter {
            let footer = TableViewRefresh(frame: CGRect.zero)
            footer.isHeader = false
            //footer.dragingText = "上拉刷新"
            //footer.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            footerView = footer
        }
        
        if emptyView == nil {
            let label = UILabel(frame: CGRect.zero)
            label.text = emptyText
            label.textColor = emptyTextColor
            emptyLabel = label
            
            let view = UIView(frame: bounds)
            view.backgroundColor = emptyViewColor
            view.addSubview(label)
            Layouter(superview: view, view: label).center()
            
            emptyView = view
        }
    }
    
    // MARK: - Header Views
    
    var headerView: TableViewRefreshProtocol? {
        didSet { updateHeaderView(old: oldValue) }
    }
    var headerTopLayout: NSLayoutConstraint?
    
    fileprivate func updateHeaderView(old: TableViewRefreshProtocol?) {
        (old as? UIView)?.removeFromSuperview()
        headerTopLayout = nil
        
        if let view = headerView as? UIView {
            addSubview(view)
            Layouter(superview: self, view: view).centerX().width().heightSelf(0, related: .greaterThanOrEqual).layout(edge: .bottom, to: .top, priority: 750).top().constrants(last: {
                self.headerTopLayout = $0
            })
        }
    }
    
    // MARK: - Footer Views
    
    var footerView: TableViewRefreshProtocol? {
        didSet { updateFooterView(old: oldValue) }
    }
    var footerHeightLayout: NSLayoutConstraint?
    var footerBottomLayout: NSLayoutConstraint?
    
    fileprivate func updateFooterLayout() -> CGFloat {
        if contentOffset.y >= 0 {
            let space = contentSize.height - bounds.height
            let offset = space > 0 ? contentOffset.y - space : contentOffset.y
            footerHeightLayout?.constant = offset > 0 ? offset : 0
            footerBottomLayout?.constant = (contentSize.height > bounds.height ? contentSize.height : bounds.height) + offset
            return offset
        } else {
            return -1
        }
    }
    
    fileprivate func updateFooterView(old: TableViewRefreshProtocol?) {
        (old as? UIView)?.removeFromSuperview()
        footerHeightLayout = nil
        footerBottomLayout = nil
        
        if let view = footerView as? UIView {
            addSubview(view)
            Layouter(superview: self, view: view).centerX().width().heightSelf().bottom(bounds.height).constrants(block: { (layouts) in
                self.footerHeightLayout = layouts[2]
                self.footerBottomLayout = layouts[3]
            })
        }
    }
    
    // MARK: - Status
    
    var status = TableViewRefreshStatus.normal {
        didSet {
            statusUpdated()
        }
    }
    
    fileprivate func statusUpdated() {
        switch status {
        case .normal:
            break
        case .header(let header):
            headerStatusUpdate(viewStatus: header)
        case .footer(let footer):
            footerStatusUpdate(viewStatus: footer)
        }
    }
    
    fileprivate func headerStatusUpdate(viewStatus: TableViewRefreshViewStatus) {
        switch viewStatus {
        case .refreshing(let value):
            if value == -1 {
                self.headerTopLayout?.constant = -self.headerView!.viewHeight
                UIView.animate(withDuration: 0.2, animations: {
                    self.contentInset.top = self.headerView!.viewHeight
                    self.contentOffset.y = -self.headerView!.viewHeight
                    self.layoutIfNeeded()
                }, completion: { _ in
                    self.status = .header(.refreshing(0))
                    self.headerRefreshStart()
                })
                return
            }
        case .finished(_):
            DispatchQueue.global().async {
                Thread.sleep(forTimeInterval: 2)
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.contentInset.top = 0
                        self.layoutIfNeeded()
                    }, completion: { _ in
                        self.headerView?.reset()
                        self.status = .normal
                    })
                }
            }
        default:
            break
        }
        headerView?.update(status: viewStatus)
    }
    
    fileprivate func footerStatusUpdate(viewStatus: TableViewRefreshViewStatus) {
        switch viewStatus {
        case .refreshing(let value):
            if value == -1 {
                self.footerHeightLayout?.constant = self.footerView!.viewHeight
                UIView.animate(withDuration: 0.2, animations: {
                    self.contentInset.bottom = self.footerView!.viewHeight
                    self.contentOffset.y = self.contentSize.height - self.bounds.height + self.footerView!.viewHeight
                    self.layoutIfNeeded()
                }, completion: { _ in
                    self.status = .footer(.refreshing(0))
                    self.footerRefreshStart()
                })
                return
            }
        case .finished(_):
            DispatchQueue.global().async {
                Thread.sleep(forTimeInterval: 2)
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.2, animations: {
                        // Height
                        let space = self.contentSize.height - self.bounds.height
                        let offset = space > 0 ? self.contentOffset.y - space : self.contentOffset.y
                        self.footerHeightLayout?.constant = offset > 0 ? offset : 0
                        self.footerBottomLayout?.constant = (self.contentSize.height > self.bounds.height ? self.contentSize.height : self.bounds.height) + offset
                        // Inset
                        self.contentInset.bottom = 0
                        
                        self.layoutIfNeeded()
                    }, completion: { _ in
                        self.footerView?.reset()
                        self.status = .normal
                    })
                }
            }
        default:
            break
        }
        footerView?.update(status: viewStatus)
    }
    
    // MARK: - Network
    
    func update(refreshProgress value: CGFloat) {
        if value < 0 || value > 1 {
            return
        }
        
        switch status {
        case .header(.refreshing(_)):
            status = .header(.refreshing(value))
        case .footer(.refreshing(_)):
            status = .footer(.refreshing(value))
        default:
            break
        }
    }
    
    fileprivate func headerRefreshStart() {
        print("headerRefreshStart \(refreshDelegate) ")
        refreshDelegate?.tableView(headerRefresh: { (finish, text) in
            DispatchQueue.main.async {
                self.status = .header(.finished(finish, text))
            }
        })
    }
    
    fileprivate func footerRefreshStart() {
        refreshDelegate?.tableView(footerRefresh: { (finish, text) in
            DispatchQueue.main.async {
                self.status = .footer(.finished(finish, text))
            }
        })
    }
    
    // MARK: - Empty View
    
    @IBOutlet var emptyView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if emptyView != nil {
                insertSubview(emptyView!, at: 0)
                Layouter(superview: self, view: emptyView!).center().size()
                emptyView?.isHidden = (oldValue?.isHidden ?? true)
            }
        }
    }
    
    override var contentSize: CGSize {
        didSet {
            if emptyView != nil {
                if contentSize.height == 0 {
                    emptyView?.isHidden = false
                } else {
                    emptyView?.isHidden = true
                }
            }
        }
    }
    
    weak var emptyLabel: UILabel?
    
    @IBInspectable var emptyText: String? {
        didSet { emptyLabel?.text = emptyText }
    }
    @IBInspectable var emptyTextColor: UIColor = UIColor(red: 50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 1) {
        didSet { emptyLabel?.textColor = emptyTextColor }
    }
    @IBInspectable var emptyViewColor: UIColor = UIColor.clear {
        didSet { emptyView?.backgroundColor = emptyViewColor }
    }
}


extension TableView: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerTopLayout?.constant = contentOffset.y
        let footerOffset = updateFooterLayout()
        
        switch status {
        case .normal:
            if contentOffset.y < 0 && headerView != nil {
                status = .header(.draging(-contentOffset.y / headerView!.viewHeight))
            } else if contentOffset.y > 0 && footerView != nil && footerOffset >= 0 {
                status = .footer(.draging(footerOffset / footerView!.viewHeight))
            }
        case .header(.draging(_)):
            if contentOffset.y < 0 {
                status = .header(.draging(-contentOffset.y / headerView!.viewHeight))
            } else {
                status = .normal
            }
        case .footer(.draging(_)):
            if footerOffset >= 0 {
                status = .footer(.draging(footerOffset / footerView!.viewHeight))
            } else {
                status = .normal
            }
        default:
            break
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        switch status {
        case .header(.willRefresh):
            status = .header(.refreshing(-1))
        case .footer(.willRefresh):
            status = .footer(.refreshing(-1))
        default:
            break
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        switch status {
        case .header(.draging(_)):
            if -contentOffset.y > headerView!.viewHeight {
                status = .header(.willRefresh)
            }
        case .footer(.draging(_)):
            if footerHeightLayout!.constant > footerView!.viewHeight {
                status = .footer(.willRefresh)
            }
        default:
            break
        }
    }
}

/* Delegate 回调
extension PoneLittleVideosController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tableView.scrollViewDidScroll(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        tableView.scrollViewDidEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        tableView.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
}
*/

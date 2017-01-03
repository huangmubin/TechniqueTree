//
//  Notifiers.swift
//  Nightjar2
//
//  Created by 黄穆斌 on 16/11/9.
//  Copyright © 2016年 Langpai. All rights reserved.
//

import Foundation

// MARK: - Notify

/** 对 Notification 进行包裹，并提供建议的访问方法。 */
class Notify {

    var notification: Notification
    var object: Any? { return notification.object }
    var name: Notification.Name { return notification.name }
    
    var pid: Int {
        return (notification.userInfo?["pid"] as? Int) ?? -1
    }
    var id: String {
        return (notification.userInfo?["id"] as? String) ?? ""
    }
    var value: String {
        return (notification.userInfo?["value"] as? String) ?? ""
    }
    var result: Bool {
        return (notification.userInfo?["result"] as? Bool) ?? false
    }
    var section: Int {
        return (notification.userInfo?["section"] as? Int) ?? 0
    }
    var row: Int {
        return (notification.userInfo?["row"] as? Int) ?? 0
    }
    var size: Int {
        return (notification.userInfo?["size"] as? Int) ?? 0
    }
    var datasize: Int {
        return (notification.userInfo?["datasize"] as? Int) ?? 0
    }
    
    init(info: Notification) {
        self.notification = info
    }
    
    subscript(key: AnyHashable) -> Any? {
        return notification.userInfo?[key]
    }
    
}

// MARK: - Notifiers Ptorocol

/** 通知器协议，遵守该协议的对象即可拥有监听，取消监听以及发送消息的功能。 */
protocol Notifiers { }
extension Notifiers {
    
    func observer(name: NSNotification.Name, selector: Selector, object: Any? = nil) {
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: object)
    }
    
    func unobserver(name: NSNotification.Name? = nil, object: Any? = nil) {
        NotificationCenter.default.removeObserver(self, name: name, object: object)
    }
    
    func post(name: NSNotification.Name, infos: [AnyHashable: Any]? = nil) {
        NotificationCenter.default.post(name: name, object: self, userInfo: infos)
    }
    
    func post(name: NSNotification.Name, infos: [AnyHashable: Any]? = nil, inQueue: DispatchQueue) {
        inQueue.async {
            NotificationCenter.default.post(name: name, object: self, userInfo: infos)
        }
    }
    
}

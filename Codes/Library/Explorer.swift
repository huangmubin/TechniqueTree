//
//  Explorer.swift
//  Socket
//
//  Created by 黄穆斌 on 16/10/31.
//  Copyright © 2016年 MuBinHuang. All rights reserved.
//

import Foundation

// MARK: - Explorer File And Folder Struct

extension Explorer {
    
    struct File {
        
        var folder: String
        var name: String
        var time: TimeInterval
        
        var shortPath: String { return folder + name }
        var path: String { return Folder.home + folder + name }
        
    }
    
    enum Folders: String {
        
        /// 根目录
        static let home: String = NSHomeDirectory()
        
        
        /// Documents 文件夹。iTunes 备份，程序中用到的文件数据。
        case documents = "/Documents/"
        /// Library/Preferences 文件夹。默认设置或状态信息。iTunes 备份。
        case preferences = "/Library/Preferences/"
        /// Library/Caches 文件夹。缓存文件，不会自动删除。
        case caches = "/Library/Caches/"
        /// tmp/ 文件夹。临时文件，系统可能删除其内容。
        case tmp = "/tmp/"
        
        
        subscript(folder: String, file: String) -> File {
            return File(folder: rawValue + folder, name: file, time: Explorer.Time.forever[0])
        }
        subscript(folder: String, file: String, time: TimeInterval) -> File {
            return File(folder: rawValue + folder, name: file, time: time)
        }
        subscript(file: String) -> File {
            return File(folder: rawValue, name: file, time: Explorer.Time.forever[0])
        }
        subscript(file: String, time: TimeInterval) -> File {
            return File(folder: rawValue, name: file, time: time)
        }
    }
    
    enum Folder: String {
        
        /// 根目录
        static let home: String      = NSHomeDirectory()
        /// Documents 文件夹。iTunes 备份，程序中用到的文件数据。
        static let documents: String = "\(NSHomeDirectory())/Documents/"
        /// Library/Preferences 文件夹。默认设置或状态信息。iTunes 备份。
        static let library: String   = "\(NSHomeDirectory())/Library/Preferences/"
        /// Library/Caches 文件夹。缓存文件，不会自动删除。
        static let caches: String    = "\(NSHomeDirectory())/Library/Caches/"
        /// tmp/ 文件夹。临时文件，系统可能删除其内容。
        static let tmp: String       = "\(NSHomeDirectory())/tmp"
        
        
        public var folder: String { return Folder.home + rawValue }
        
        subscript(file: String) -> File {
            return File(folder: rawValue, name: file, time: Explorer.Time.forever[0])
        }
        subscript(file: String, time: TimeInterval) -> File {
            return File(folder: rawValue, name: file, time: time)
        }
        
        case image = "Images/"
        case video = "Videos/"
        case text  = "Texts/"
    }

}


// MARK: - Explorer Time

extension Explorer {
    
    enum Time: TimeInterval {
        
        subscript(count: TimeInterval) -> TimeInterval {
            return rawValue * count + Date().timeIntervalSince1970
        }
        
        case hour    = 3600.0
        case day     = 86400.0
        case weak    = 604800.0
        case month   = 2592000.0
        case forever = 97830720000.0
        
        static let pointer = 97830720000.0
    }
    
}

// MARK: - Explorer

/**
 用于管理文件的类
 */
public class Explorer: NSObject {

}

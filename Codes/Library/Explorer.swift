//
//  Explorer.swift
//  Socket
//
//  Created by 黄穆斌 on 16/10/31.
//  Copyright © 2016年 MuBinHuang. All rights reserved.
//

import Foundation

// MARK: - Explorer

/**
 用于管理文件的类
 */
public class Explorer {
    
    // MAKR: - File Managers
    
    /// 检查文件是否存在
    public class func exist(file: String) -> Bool {
        return FileManager.default.fileExists(atPath: file)
    }
    
    /// 获取文件数据
    public class func read(file: String) -> Data? {
        return FileManager.default.contents(atPath: file)
    }
    
    /// 创建文件夹
    public class func create(directory: String) -> Bool {
        do {
            try FileManager.default.createDirectory(at: URL(fileURLWithPath: directory), withIntermediateDirectories: true, attributes: nil)
            return true
        } catch { }
        return false
    }
    
    /// 保存文件
    public class func save(data: Data, to: String) -> Bool {
        do {
            try data.write(to: URL(fileURLWithPath: to))
            return true
        } catch { }
        return false
    }
    
    /// 删除文件
    public class func delete(file: String) -> Bool {
        do {
            try FileManager.default.removeItem(atPath: file)
            return true
        } catch { }
        return false
    }
    
    /// 拷贝文件
    public class func copy(file: String, to: String) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: file) {
                //try FileManager.default.createDirectory(at: URL(fileURLWithPath: file), withIntermediateDirectories: true, attributes: nil)
                try FileManager.default.copyItem(atPath: file, toPath: to)
                return true
            }
        } catch { }
        return false
    }
    
    /// 移动文件
    public class func move(file: String, to: String) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: file) {
                try FileManager.default.createDirectory(at: URL(fileURLWithPath: file), withIntermediateDirectories: true, attributes: nil)
                try FileManager.default.moveItem(atPath: file, toPath: to)
                return true
            }
        } catch { }
        return false
    }
    
}

// MARK: - Explorer File And Folder Struct

extension Explorer {
    
    // MARK: Path 路径
    
    public struct Path {
        
        /* 根目录 */
        /***************************************/
        
        /// 根目录
        static let home: String = NSHomeDirectory()
        
        /* 标准文件结构路径 */
        /***************************************/
        
        /// Documents 文件夹。iTunes 备份，程序中用到的文件数据。
        static let documents = "/Documents/"
        /// Library/Preferences 文件夹。默认设置或状态信息。iTunes 备份。
        static let preferences = "/Library/Preferences/"
        /// Library/Caches 文件夹。缓存文件，不会自动删除。
        static let caches = "/Library/Caches/"
        /// tmp/ 文件夹。临时文件，系统可能删除其内容。
        static let tmp = "/tmp/"
        
        /* 通过文件名获取文件信息 home/folder/file */
        /***************************************/
        
        static func documents(_ file: String) -> String {
            return home + Path.documents + file
        }
        static func preferences(_ file: String) -> String {
            return home + Path.preferences + file
        }
        static func caches(_ file: String) -> String {
            return home + Path.caches + file
        }
        static func tmp(_ file: String) -> String {
            return home + Path.tmp + file
        }
        
    }
    
}

// MARK: - 自定义文件夹路径实例

enum FilePath: String {
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
    
    /// 获取文件路径
    subscript(file: String) -> String {
        return FilePath.home + rawValue + file
    }
    
}

// MARK: - Explorer Time

extension Explorer {
    
    /**
     时间管理信息
     */
    enum Time: TimeInterval {
        
        subscript(count: TimeInterval) -> TimeInterval {
            return rawValue * count + Date().timeIntervalSince1970
        }
        
        case hour    = 3600.0
        case day     = 86400.0
        case weak    = 604800.0
        case month   = 2592000.0
        case forever = 97830720000.0
        
        static let flag = 97830720000.0
    }
    
}

// MARK: - Explorer Size

extension Explorer {
    
    /**
     尺寸大小
     */
    enum Size: Double {
        
        case Bytes  = 1
        case KB     = 1000
        case MB     = 1000000
        case GB     = 1000000000
        
        static func bytes(path: String) -> UInt {
            guard let attribute = try? FileManager.default.attributesOfItem(atPath: path) else { return 0 }
            guard let type = attribute[FileAttributeKey.type] as? String else { return 0 }
            if type == FileAttributeType.typeDirectory.rawValue {
                var size: UInt = 0
                guard let subPaths = FileManager.default.subpaths(atPath: path) else { return 0 }
                for sub in subPaths {
                    let subPath = "\(path)\(path.hasSuffix("/") ? "" : "/")\(sub)"
                    guard let subAtt = try? FileManager.default.attributesOfItem(atPath: subPath) else { continue }
                    guard let type = subAtt[FileAttributeKey.type] as? String else { continue }
                    if type != FileAttributeType.typeDirectory.rawValue {
                        guard let s = subAtt[FileAttributeKey.size] as? UInt else { continue }
                        size += s
                    }
                }
                return size
            } else {
                guard let size = attribute[FileAttributeKey.size] as? UInt else { return 0 }
                return size
            }
        }
        
        /// 判断路径，如果是文件夹则搜索底下所有文件的大小之和
        subscript(path: String) -> Double? {
            guard let attribute = try? FileManager.default.attributesOfItem(atPath: path) else { return nil }
            guard let type = attribute[FileAttributeKey.type] as? String else { return nil }
            if type == FileAttributeType.typeDirectory.rawValue {
                var size: UInt = 0
                guard let subPaths = FileManager.default.subpaths(atPath: path) else { return nil }
                for sub in subPaths {
                    let subPath = "\(path)\(path.hasSuffix("/") ? "" : "/")\(sub)"
                    guard let subAtt = try? FileManager.default.attributesOfItem(atPath: subPath) else { continue }
                    guard let type = subAtt[FileAttributeKey.type] as? String else { continue }
                    if type != FileAttributeType.typeDirectory.rawValue {
                        guard let s = subAtt[FileAttributeKey.size] as? UInt else { continue }
                        size += s
                    }
                }
                return Double(size) / rawValue
            } else {
                guard let size = attribute[FileAttributeKey.size] as? UInt else { return nil }
                return Double(size) / rawValue
            }
        }
        
    }
}

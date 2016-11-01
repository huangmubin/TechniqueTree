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
public class Explorer: NSObject {
    
    // MAKR: - File Managers
    
    /// 检查文件是否存在
    public class func exist(file: String) -> Bool {
        return FileManager.default.fileExists(atPath: file)
    }
    
    /// 获取文件数据
    public class func read(file: String) -> Data? {
        return FileManager.default.contents(atPath: file)
    }
    
    /// 保存文件
    public class func save(data: Data, to: String) -> Bool {
        do {
            try FileManager.default.createDirectory(at: URL(fileURLWithPath: to), withIntermediateDirectories: true, attributes: nil)
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
                try FileManager.default.createDirectory(at: URL(fileURLWithPath: file), withIntermediateDirectories: true, attributes: nil)
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
    
    // MARK: File 文件结构
    
    /**
     文件结构
     */
    public struct File {
        
        var folder: String
        var name: String
        
        /// 完整路径
        var path: String { return Folders.home + folder + name }
        /// 应用内路径(文件唯一标示符)
        var id: String { return folder + name }
    }
    
    
    // MARK: Folders 文件夹枚举
    public enum Folders: String {
        
        /* 根目录 */
        /***************************************/
        
        /// 根目录
        static let home: String = NSHomeDirectory()
        
        /* 标准文件结构路径 */
        /***************************************/
        
        /// Documents 文件夹。iTunes 备份，程序中用到的文件数据。
        case documents = "/Documents/"
        /// Library/Preferences 文件夹。默认设置或状态信息。iTunes 备份。
        case preferences = "/Library/Preferences/"
        /// Library/Caches 文件夹。缓存文件，不会自动删除。
        case caches = "/Library/Caches/"
        /// tmp/ 文件夹。临时文件，系统可能删除其内容。
        case tmp = "/tmp/"
        
        /* 通过文件名获取文件信息 home/rawValue/file */
        /***************************************/
        
        subscript(file: String) -> File {
            return File(folder: rawValue, name: file)
        }
        
        /* 通过手写文件夹路径创建文件信息 home/rawValue/folder/file */
        /***************************************/
        
        subscript(folder: String, file: String) -> File {
            return File(folder: rawValue + folder, name: file)
        }
        
        /* 通过扩展文件夹名称获取文件信息 home/rawValue/Name.value/file */
        /***************************************/
        
        // 用于扩展文件夹路径
        public struct Name {
            let value: String
            init(_ value: String) {
                self.value = value
            }
            static let images = Name("Images/")
            static let videos = Name("Videos/")
            static let temps = Name("Temps/")
        }
        
        subscript(folder: Name, file: String) -> File {
            return File(folder: rawValue + folder.value, name: file)
        }
        
        /* 获取文件夹路径 home/rawValue/Name.value */
        /***************************************/
        
        subscript(folder: Name) -> String {
            return Folders.home + rawValue + folder.value
        }
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
        
        /// 判断路径，如果是文件夹则搜索底下所有文件的大小，否则搜搜该文件大小 ？如果是文件夹 size 有没有效果？
        subscript(path: String) -> Double? {
            guard let attribute = try? FileManager.default.attributesOfItem(atPath: path) else { return nil }
            guard let type = attribute[FileAttributeKey.type] as? String else { return nil }
            if type == FileAttributeType.typeDirectory.rawValue {
                var size: UInt = 0
                guard let subPaths = FileManager.default.subpaths(atPath: path) else { return nil }
                for subPath in subPaths {
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


// MARK: - UserDefaults

class UserExporer {
    
    // MARK: Property
    
    static let `default` =  UserExporer()
    private var suite: UserDefaults
    private var lock: DispatchQueue
    
    // MARK: Init
    
    init() {
        if let user = UserDefaults(suiteName: "Explorer_File_Index") {
            suite = user
        } else {
            UserDefaults.standard.addSuite(named: "Explorer_File_Index")
            suite = UserDefaults(suiteName: "Explorer_File_Index")!
        }
        lock = DispatchQueue(label: "com.Lock.Explorer.Index.UserDefaults", qos: DispatchQoS.userInteractive)
    }
    
    // MARK: Time
    
    func change(file: Explorer.File, time: TimeInterval) -> Bool {
        return lock.sync {
            if let value = self.suite.dictionary(forKey: file.id) {
                if let name = value["name"] as? String, let folder = value["folder"] as? String {
                    self.suite.set(["name": name, "folder": folder, "time": time], forKey: file.id)
                    return true
                }
            }
            return false
        }
    }
    
    // MARK: Files Operations
    
    func exist(file: Explorer.File) -> Bool {
        return lock.sync {
            return Explorer.exist(file: file.path)
        }
    }
    
    func save(data: Data?, file: Explorer.File, time: TimeInterval = Explorer.Time.forever[0]) -> Bool {
        guard let data = data else { return false }
        return lock.sync {
            if Explorer.save(data: data, to: file.path) {
                self.suite.set(["name": file.name, "folder": file.folder, "time": time], forKey: file.id)
                return true
            }
            return false
        }
    }
    
    func delete(file: Explorer.File) -> Bool {
        return lock.sync {
            if Explorer.delete(file: file.path) {
                self.suite.removeObject(forKey: file.id)
                return true
            }
            return false
        }
    }
    
    func move(file: Explorer.File, to: Explorer.File, time: TimeInterval = Explorer.Time.forever[0]) -> Bool {
        return lock.sync {
            if Explorer.move(file: file.path, to: to.path) {
                self.suite.removeObject(forKey: file.id)
                self.suite.set(["name": to.name, "folder": to.folder, "time": time], forKey: to.id)
                return true
            }
            return false
        }
    }
    
    func copy(file: Explorer.File, to: Explorer.File, time: TimeInterval = Explorer.Time.forever[0]) -> Bool {
        return lock.sync {
            if Explorer.copy(file: file.path, to: to.path) {
                self.suite.set(["name": to.name, "folder": to.folder, "time": time], forKey: to.id)
                return true
            }
            return false
        }
    }
    
}

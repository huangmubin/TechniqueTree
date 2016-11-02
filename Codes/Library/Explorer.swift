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
        var size: Double = 0
        var time: Double = 0
        
        /// 完整路径
        var path: String { return Folders.home + folder + name }
        /// 应用内路径(文件唯一标示符)
        var id: String { return folder + name }
        
        init(folder: String, name: String) {
            self.folder = folder
            self.name   = name
        }
        init(folder: String, name: String, size: Double, time: Double) {
            self.folder = folder
            self.name   = name
            self.size   = size
            self.time   = time
        }
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

// MARK: - Explorer Type

extension Explorer {
    enum ClearType {
        case size
        case time
        case all
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
        lock = DispatchQueue(label: "com.Lock.Explorer.Index.UserDefaults")
    }
    
    // MARK: Clear
    
    static var clearType: Explorer.ClearType = Explorer.ClearType.all
    /// 100 MB
    static var maxMemory: Double = 1000000 * 100
    
    func clear() {
        DispatchQueue.global().async {
            var files: [Explorer.File] = []
            self.suite.dictionaryRepresentation().forEach({
                if let values = $0.value as? [String: Any] {
                    if let name = values["name"] as? String, let folder = values["folder"] as? String, let time = values["time"] as? Double, let size = values["size"] as? UInt {
                        files.append(Explorer.File.init(folder: folder, name: name, size: Double(size), time: time))
                    }
                }
            })
            let time = Date().timeIntervalSince1970
            var size: Double = 0
            if UserExporer.clearType == .time {
                files.forEach ({
                    if $0.time < time {
                        self.delete(file: $0)
                    }
                })
            } else if UserExporer.clearType == .size {
                files.sort(by: { $0.time > $1.time })
                for file in files {
                    if size < UserExporer.maxMemory {
                        size += file.size
                    } else {
                        self.delete(file: file)
                    }
                }
            } else {
                files.sort(by: { $0.time > $1.time })
                for file in files {
                    if size < UserExporer.maxMemory && file.time > time {
                        size += file.size
                    } else {
                        self.delete(file: file)
                    }
                }
            }
        }
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
    
    func read(file: Explorer.File) -> Data? {
        return lock.sync {
            return Explorer.read(file: file.path)
        }
    }
    
    func save(data: Data?, file: Explorer.File, time: TimeInterval = Explorer.Time.forever[0]) -> Bool {
        guard let data = data else { return false }
        return lock.sync {
            if Explorer.save(data: data, to: file.path) {
                self.suite.set(["name": file.name, "folder": file.folder, "time": time, "size": Explorer.Size.bytes(path: file.path)], forKey: file.id)
                return true
            }
            return false
        }
    }
    
    @discardableResult func delete(file: Explorer.File) -> Bool {
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
                self.suite.set(["name": to.name, "folder": to.folder, "time": time, "size": Explorer.Size.bytes(path: to.path)], forKey: to.id)
                return true
            }
            return false
        }
    }
    
    func copy(file: Explorer.File, to: Explorer.File, time: TimeInterval = Explorer.Time.forever[0]) -> Bool {
        return lock.sync {
            if Explorer.copy(file: file.path, to: to.path) {
                self.suite.set(["name": to.name, "folder": to.folder, "time": time, "size": Explorer.Size.bytes(path: to.path)], forKey: to.id)
                return true
            }
            return false
        }
    }
    
}

// MARK: - CoreData

import CoreData

/**
 使用之前需要先设置 entityName 为当前实体的名称，比如 CoreDataExplorer.
 并通过 AppDelegate 或其他位置获取 coredata 堆栈中的 managedObjectContext 并进行设置。
 */
public class CoreDataExplorer: NSManagedObject {
    
    // MARK: Static Properties
    
    static var entityName = "EntityName"
    static weak var managedObjectContext: NSManagedObjectContext?
    static var lock = DispatchQueue(label: "com.Lock.Explorer.Index.CoreData")
    
    // MARK: Properties
    
    @NSManaged public var explorer_name: String?
    @NSManaged public var explorer_folder: String?
    @NSManaged public var explorer_time: Double
    @NSManaged public var explorer_size: Double
    var path: String {
        return Explorer.Folders.home + (explorer_folder ?? "") + (explorer_name ?? "")
    }
    
    // MARK: Clear
    
    static var clearType: Explorer.ClearType = Explorer.ClearType.all
    /// 100 MB
    static var maxMemory: Double = 1000000 * 100
    
    func clear() {
        
    }
    
    // MARK: File Methods
    
    func exist() -> Bool {
        return CoreDataExplorer.lock.sync {
            return Explorer.exist(file: path)
        }
    }
    
    func read() -> Data? {
        return CoreDataExplorer.lock.sync {
            return Explorer.read(file: path)
        }
    }
    
    func save(data: Data?, file: Explorer.File, time: TimeInterval = Explorer.Time.forever[0]) -> Bool {
        guard let data = data else { return false }
        return CoreDataExplorer.lock.sync {
            if Explorer.save(data: data, to: file.path) {
                self.explorer_name   = file.name
                self.explorer_folder = file.folder
                self.explorer_time   = time
                self.explorer_size   = Double(Explorer.Size.bytes(path: file.path))
                return true
            }
            return false
        }
    }
    
    func delete(file: Explorer.File) -> Bool {
        return CoreDataExplorer.lock.sync {
            if Explorer.delete(file: file.path) {
                self.explorer_size   = 0
                return true
            }
            return false
        }
    }
    
    func move(file: Explorer.File, to: Explorer.File, time: TimeInterval = Explorer.Time.forever[0]) -> Bool {
        return CoreDataExplorer.lock.sync {
            if Explorer.move(file: file.path, to: to.path) {
                self.explorer_name   = to.name
                self.explorer_folder = to.folder
                self.explorer_time   = time
                self.explorer_size   = 0
                return true
            }
            return false
        }
    }
    
    // MARK: Common Methods
    
    class func fetch(exist: String, sorts: [(String, Bool)]? = nil) -> Bool {
        return lock.sync {
            if let context = managedObjectContext {
                do {
                    let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
                    request.predicate = NSPredicate(format: exist)
                    if let sortTuple = sorts {
                        var descriptors = [NSSortDescriptor]()
                        for sort in sortTuple {
                            descriptors.append(NSSortDescriptor(key: sort.0, ascending: sort.1))
                        }
                        request.sortDescriptors = descriptors
                    }
                    let result = try context.fetch(request)
                    return result.count > 0
                } catch {
                    fatalError("Failed to fetch employees: \(error)")
                }
            }
            return false
        }
    }
    
    @discardableResult class func saveContext() -> Bool {
        return lock.sync {
            if let context = managedObjectContext {
                if context.hasChanges {
                    do {
                        try context.save()
                        return true
                    } catch {
                        let nserror = error as NSError
                        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                    }
                }
            }
            return false
        }
    }
    
    class func insert() -> NSManagedObject? {
        return lock.sync {
            if let context = managedObjectContext {
                return NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
            }
            return nil
        }
    }
    
    class func delete(object: NSManagedObject) -> Bool {
        return lock.sync {
            if let context = managedObjectContext {
                context.delete(object)
                return true
            }
            return false
        }
    }
    
}


// MARK: - Core Data stack before iOS 10.0
/*
 
lazy var applicationDocumentsDirectory: URL = {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.langpai.MoeNightjarSwift" in the application's documents Application Support directory.
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return urls[urls.count-1]
}()

lazy var managedObjectModel: NSManagedObjectModel = {
    // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
    let modelURL = Bundle.main.url(forResource: "Nightjar", withExtension: "momd")!
    return NSManagedObjectModel(contentsOf: modelURL)!
}()

lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
    // Create the coordinator and store
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
    var failureReason = "There was an error creating or loading the application's saved data."
    do {
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
    } catch {
        // Report any error we got.
        var dict = [String: AnyObject]()
        dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
        dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
        
        dict[NSUnderlyingErrorKey] = error as NSError
        let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
        abort()
    }
    
    return coordinator
}()

lazy var managedObjectContext: NSManagedObjectContext = {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
    let coordinator = self.persistentStoreCoordinator
    var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = coordinator
    return managedObjectContext
}()

// MARK: - Core Data Saving support

func saveContext () {
    if managedObjectContext.hasChanges {
        do {
            try managedObjectContext.save()
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
}

*/



// MARK: - Core Data stack after ios 10.0
/*
lazy var persistentContainer: NSPersistentContainer = {
    /*
     The persistent container for the application. This implementation
     creates and returns a container, having loaded the store for the
     application to it. This property is optional since there are legitimate
     error conditions that could cause the creation of the store to fail.
     */
    let container = NSPersistentContainer(name: "iOSCoreData")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        if let error = error as NSError? {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            
            /*
             Typical reasons for an error here include:
             * The parent directory does not exist, cannot be created, or disallows writing.
             * The persistent store is not accessible, due to permissions or data protection when the device is locked.
             * The device is out of space.
             * The store could not be migrated to the current model version.
             Check the error message to determine what the actual problem was.
             */
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    })
    return container
}()

// MARK: - Core Data Saving support

func saveContext () {
    let context = persistentContainer.viewContext
    if context.hasChanges {
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
*/

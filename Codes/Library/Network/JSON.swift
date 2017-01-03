//
//  JSON.swift
//  Socket
//
//  Created by 黄穆斌 on 16/10/30.
//  Copyright © 2016年 MuBinHuang. All rights reserved.
//

import Foundation

/// Json 数据封装处理对象
class JSON {

    /// 原始数据
    var json: Any?
    /// 临时处理数据
    var temp: Any?
    
    /// 重置临时数据
    func reset() {
        self.temp = self.json
    }
    /// 将数据初始化到当前位置
    func cut() {
        self.json = self.temp
    }
    
    // MARK: - Init
    
    init(json: Any?) {
        self.json = json
        self.temp = json
    }
    
    init(data: Data?) {
        if let d = data {
            if let json = try? JSONSerialization.jsonObject(with: d, options: JSONSerialization.ReadingOptions.allowFragments) {
                //print("JSON init(data: Data?) \n\(json)")
                self.json = json
                self.temp = json
            }
        }
    }
    
    // MARK: - Subscript
    
    /// 通过下标层层解压
    subscript(keys: Any...) -> JSON {
        var temp = self.temp
        for value in keys {
            if let json = temp as? [String: Any], let key = value as? String {
                temp = json[key]
            } else if let json = temp as? [Any], let key = value as? Int {
                temp = json[key]
            }
        }
        self.temp = temp
        return self
    }
    
    func value(_ keys: [Any]) -> JSON {
        var temp = self.temp
        for value in keys {
            if let json = temp as? [String: Any], let key = value as? String {
                temp = json[key]
            } else if let json = temp as? [Any], let key = value as? Int {
                temp = json[key]
            }
        }
        self.temp = temp
        return self
    }
    
    // MARK: - Type
    
    var int: Int? {
        let value = temp as? Int
        temp = json
        return value
    }
    var double: Double? {
        let value = temp as? Double
        temp = json
        return value
    }
    var string: String? {
        let value = temp as? String
        temp = json
        return value
    }
    var intValue: Int {
        return type(0)
    }
    var doubleValue: Double {
        return type(0.0)
    }
    var stringValue: String {
        return type("")
    }
    var array: [JSON] {
        if let data = temp as? [Any] {
            temp = json
            var jsons = [JSON]()
            for value in data {
                jsons.append(JSON(json: value))
            }
            return jsons
        }
        temp = json
        return []
    }
    var dictionary: [String: JSON] {
        if let data = temp as? [String: Any] {
            temp = json
            var jsons = [String: JSON]()
            for (key, value) in data {
                jsons[key] = JSON(json: value)
            }
            return jsons
        }
        temp = json
        return [:]
    }
    
    // MARK: - 判断方法
    
    /// 检查某个下标是否存在
    func exist(keys: Any...) -> Bool {
        var temp = self.temp
        for value in keys {
            if let json = temp as? [String: Any], let key = value as? String {
                temp = json[key]
            } else if let json = temp as? [Any], let key = value as? Int {
                temp = json[key]
            } else {
                return false
            }
        }
        return temp != nil
    }
    
    // MARK: - 解压方法
    
    /// 将当前原始转换成为 null 元素的类型，如果成功就返回，否则返回 null
    func type<T>(_ null: T) -> T {
        if let value = temp as? T {
            temp = json
            return value
        } else {
            temp = json
            return null
        }
    }
    
    func doubleStr() -> Double {
        if let value = temp as? String {
            temp = json
            return Double(value) ?? 0
        } else {
            temp = json
            return 0
        }
    }
    
    func intStr(_ i: Int = 0) -> Int {
        if let value = temp as? String {
            temp = json
            return Int(value) ?? i
        } else {
            temp = json
            return i
        }
    }
    
    /// 将解压出来的数据强转成指定的类型。
    func get<T>(_ keys: Any...) -> T? {
        var temp = self.temp
        for value in keys {
            if let json = temp as? [String: Any], let key = value as? String {
                temp = json[key]
            } else if let json = temp as? [Any], let key = value as? Int {
                temp = json[key]
            }
        }
        return temp as? T
    }
    
    /// 如果数组当中的元素是字典类型的，将某个特定的 Key 提取组成新的数组
    func array<T>(null: T, forKey: String) -> [T] {
        if let data = temp as? [[String: Any]] {
            self.temp = self.json
            var jsons = [T]()
            for dic in data {
                if let value = dic[forKey] as? T {
                    jsons.append(value)
                }
            }
            return jsons
        }
        self.temp = self.json
        return []
    }
    
    /// 如果数组当中的元素是字典类型的，将其中的 Key 跟 Value 提取出来组成元组(这真是个令人无语的需求)
    func array<T>(null: T) -> [(String, T)] {
        if let data = temp as? [[String: Any]] {
            self.temp = self.json
            var jsons = [(String, T)]()
            for dic in data {
                for (key, value) in dic {
                    if let v = value as? T {
                        jsons.append((key, v))
                    }
                }
            }
            return jsons
        }
        self.temp = self.json
        return []
    }
}

extension JSON {
    
    /// 将类型转换成 Json 字符串(未测试)
    class func jsonstring(data: Any) -> String {
        var result = ""
        if let dic = data as? [String: Any] {
            result += "{"
            for (k, v) in dic {
                if v is Int || v is Double || v is Float {
                    result += "\"\(k)\":\(v),"
                } else if v is String {
                    result += "\"\(k)\":\"\(k)\","
                } else {
                    result += "\(jsonstring(data: v)),"
                }
            }
            result.remove(at: result.index(before: result.endIndex))
            result += "}"
        } else if let arr = data as? [Any] {
            result += "{"
            for a in arr {
                result += "\(jsonstring(data: a)),"
            }
            result.remove(at: result.index(before: result.endIndex))
            result += "}"
        }
        return result
    }
    
    class func printjson(data: Data?) {
        if let d = data {
            if let json = try? JSONSerialization.jsonObject(with: d, options: JSONSerialization.ReadingOptions.allowFragments) {
                print("JSON Print \n\(json);")
                return
            }
        }
        print("JSON Print nil;")
    }
    
}

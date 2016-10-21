---
layout: post
title: "Widgets"
description: "小工具集合"
date: 2016-10-21
tags: [Widget, Rename]
comments: true
share: false
---

> 这是一篇记录我写的所有小工具的文章。

[TOC]


# Rename 重命名工具 1.0

* 开发目的: 用于程序 icon 重命名。
* 工具实现步骤:
    * 数据结构
    * 运行参数
    * 命令行参数解析
    * 打印程序信息
    * 程序主体
        * 获取文件列表
        * 解析文件名
        * 创建新文件夹
        * 根据新文件名复制文件
    * 程序结束
* 要点:
    * 名称更别使用名称对照表来进行
    * CommandLine 获取当前命令参数
    * 检查关键字符 '@' 来获取图片的比例信息

```
import Foundation


// MARK: - 数据结构

struct File {
    var path: String = ""
    var name: String = ""
    var suffix: String = ""
    var multiple: String = ""
}

// MARK: - 运行参数

// 当前运行路径

var directoryPath = Process().currentDirectoryPath
//var directoryPath = "/Users/Myron/Resources"

// 要改名的文件后缀
let suffixes = [".png", ".jpg"]

// 文件列表
var files = [File]()

// 名称对照表
var names = [
    ("image", "newImage")
]

// MARK: - 获取命令行参数

// 获取命令行指令以更改名称对照表

if CommandLine.argc > 2 {
    names.removeAll()
    var old = ""
    var new = ""
    var i = 1
    repeat {
        old = CommandLine.arguments[i]
        new = CommandLine.arguments[i+1]
        if !old.isEmpty && !new.isEmpty {
            names.append((old, new))
        } else {
            break
        }
        i += 2
    } while CommandLine.arguments.count > i + 1
}

// MARK: - 打印程序信息

print("Start in: \(directoryPath)")

for name in names {
    print("Change \(name.0) to \(name.1)")
}

// MARK: - 程序主体

// MARK: 获取文件列表并生成文件信息
if let subPaths = try? FileManager.default.contentsOfDirectory(atPath: directoryPath) {
    for subPath in subPaths {
        for suffix in suffixes {
            // 根据文件后缀判断是否要进行重命名
            if subPath.hasSuffix(suffix) {
                // 解析文件信息
                var file = File()
                file.path = directoryPath + "/" + subPath
                file.suffix = suffix
                
                // 解析辨析率
                var nameLong = -1
                for (i,c) in subPath.characters.reversed().enumerated() {
                    if c == "@" {
                        nameLong = subPath.characters.count - i - 1
                    }
                }
                if nameLong != -1 {
                    let i0 = subPath.startIndex
                    let i1 = subPath.index(i0, offsetBy: nameLong)
                    let i2 = subPath.index(i0, offsetBy: subPath.characters.count - suffix.characters.count)
                    file.name = subPath[i0 ..< i1]
                    file.multiple = subPath[i1 ..< i2]
                } else {
                    let i0 = subPath.startIndex
                    let i1 = subPath.index(i0, offsetBy: subPath.characters.count - suffix.characters.count)
                    file.name = subPath[i0 ..< i1]
                }
                files.append(file)
            }
        }
    }
}

// MARK: 创建新文件夹
let _ = try? FileManager.default.createDirectory(atPath: directoryPath + "/NewNames", withIntermediateDirectories: true, attributes: nil)

// MAKR: 复制文件
for file in files {
    if let index = names.index(where: { $0.0 == file.name }) {
        if let data = try? Data(contentsOf: URL(fileURLWithPath: file.path)) {
            let _ = try? data.write(to: URL(fileURLWithPath: directoryPath + "/NewNames/" + names[index].1 + file.multiple + file.suffix))
        }
    }
}

// MARK: 程序结束
print("Done")
```


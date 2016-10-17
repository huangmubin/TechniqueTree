---
layout: post
title: "linux 命令行"
description: "记录 linux 环境下的命令行命令"
date: 2016-10-15
tags: [Mac OS,Linux]
comments: true
share: false
---


# 常用命令

* 路径移动:                cd <path>
    * 移动到上一个文件夹: ..
    * 移动到根目录:      ~
* 显示文件信息:             ls
    * 显示完整的文件信息:  -l
* 执行程序:                 ./<a.out>
* 打印内容:                 echo <some thing>
* 查看帮助文档:              man <...>

# 编译程序

* 编译文件:                 gcc <file> 
    * 编译成指定文件:        gcc <file> -output <new file name>
    * 使用特定的进制来编译:   gcc <file> -output <new file name> -m32

# 文件命令

* 在终端里输出文件内容: more <file>
* 删除文件和目录:      rm <file>
	* -f 向下递归
	* -r 强行删除
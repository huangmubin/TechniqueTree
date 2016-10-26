---
layout: post
title: "System"
description: "各个系统杂记"
date: 2016-10-16
tags: [System, Mac]
comments: true
share: false
---

[TOC]


# Mac OX

## 系统主题

* 设置暗色
    * 系统偏好设置 -> 通用 -> 外观 -> 使用暗色菜单栏和 Dock
* 设置桌面
    * 系统偏好设置 -> 桌面与屏幕保护程序 -> 桌面

## 最大化

* 独立全屏：左上角绿色按钮
* 铺满屏幕：option + 左上角绿色按钮

## 制作 Yosemite 系统启动盘

* 下载好新的系统，先别点击下一步。
* 插入 8G 以上 U 盘
* 使用 DiskMaker 安装，则直接按提示，否则进入下一个
* 打开磁盘工具，确定 U 盘格式是 Mac OS 
    * 否则，抹掉，重新格式化
* 打开终端输入 sudo /Applications/Install\ OS\ X\ Yosemite.app/Contents/Resources/createinstaillmedia --volume /Volumes/<<替> U 盘名称 <换>> --applicaitonpath/Applications/Install\ OS\ X\ Yosemite.app --nointeraction


---
layout: post
title: "Image"
description: "图像处理"
date: 2016-10-31
tags: [Image]
comments: true
share: false
---

# 合成

```
合成公式 
R = S + D * ( 1 - Sa )
结果颜色 = 源色彩 + 目标色彩 * ( 1 - 源色彩透明度 )
源色彩: 顶端纹理
目标色彩: 低一层纹理

示例 (每个颜色都代表 RGB 三个值)

0.5   0.5   0.0
0.0 = 0.0 + 0.0 * ( 1 - 0.5 )
0.5   0.0   1.0

如果 layer 是不透明的，需要设置 opaque 为 true。否则哪怕每个地方的 alpha 都是 1, core animation 依然会坚持是否有地方不为 1.带来性能损失。
```

# Mask 蒙版

蒙版是一个拥有 alpha 值的位图。它会决定只有 alpha 的位置才会被渲染出来。

# 离屏渲染 Offscreen Rendering

应该主动避免离屏渲染。

如果你使用 layer 的方式会通过屏幕外渲染，你最好摆脱这种方式。为 layer 使用蒙板或者设置圆角半径会造成屏幕外渲染，产生阴影也会如此。

至于 mask，圆角半径(特殊的mask)和 clipsToBounds/masksToBounds，你可以简单的为一个已经拥有 mask 的 layer 创建内容，比如，已经应用了 mask 的 layer 使用一张图片。如果你想根据 layer 的内容为其应用一个长方形 mask，你可以使用 contentsRect 来代替蒙板。

如果你最后设置了 shouldRasterize 为 YES，那也要记住设置 rasterizationScale 为 contentsScale。

# Core Graphics / Quartz 2D



# 参考资料

[ObjC 绘制像素到屏幕上](https://objccn.io/issue-3-1/)




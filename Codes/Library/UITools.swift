//
//  Image.swift
//  MYImage
//
//  Created by 黄穆斌 on 16/10/31.
//  Copyright © 2016年 Myron. All rights reserved.
//

import UIKit
import ImageIO

public class UITools {
    
    
    // MARK: - Image 图片处理
    
    // MARK: 图片保存到相册方法示例
    
    func saveToPhotosAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveToPhotosAlbumCompletion), nil)
    }
    
    @objc func saveToPhotosAlbumCompletion() {
        /* ... */
    }
    
    // MARK: 对图片进行降采样处理，减少内存占用
    
    /// 对图片数据进行降采样处理然后返回
    class func image(data: Data, size: CGSize) -> UIImage? {
        var result: UIImage? = nil
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        if let image = UIImage(data: data) {
            image.draw(in: CGRect(origin: CGPoint.zero, size: size))
            result = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return result
    }
    
    /// 在子线程中进行降采样处理，然后在主线程中进行返回。
    class func image(data: Data, size: CGSize, info: Any? = nil, complete: @escaping (UIImage?, Any?) -> Void) {
        DispatchQueue.global().async {
            var result: UIImage? = nil
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            if let image = UIImage(data: data) {
                image.draw(in: CGRect(origin: CGPoint.zero, size: size))
                result = UIGraphicsGetImageFromCurrentImageContext()
            }
            UIGraphicsEndImageContext()
            DispatchQueue.main.async {
                complete(result, info)
            }
        }
    }
    
    // MARK: 对图片进行压缩和序列化
    
    /// 将图片转为 PNG
    class func archiver(toPNG image: UIImage) -> Data? {
        return UIImagePNGRepresentation(image)
    }
    
    /// 将图片转为 JPEG, 更加快速
    class func archiver(toJPEG image: UIImage, _ compress: CGFloat) -> Data? {
        return UIImageJPEGRepresentation(image, compress)
    }
    
    // MARK: 直接获取图片解码后的数据
    
    /// 需要 ImageIO , 获取图片解码后的数据，有什么用？
    class func image(data: Data) -> CFData? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        guard let cgimage = CGImageSourceCreateImageAtIndex(source, 0, nil) else { return nil }
        return cgimage.dataProvider?.data
    }
    
}

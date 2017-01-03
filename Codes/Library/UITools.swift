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
    
    /// 对图片数据进行降采样处理然后返回
    class func image(image: UIImage, size: CGSize) -> UIImage? {
        var result: UIImage? = nil
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    /// 对图片数据进行降采样处理然后返回
    class func image(image: UIImage, width: CGFloat) -> UIImage? {
        var result: UIImage? = nil
        let height = image.size.height / image.size.width * width
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    /// 对图片数据进行降采样处理然后返回
    class func image(image: UIImage, height: CGFloat) -> UIImage? {
        var result: UIImage? = nil
        let width = image.size.width / image.size.height * height
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        result = UIGraphicsGetImageFromCurrentImageContext()
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
    
    // MARK: - 屏幕方向
    
    public class func orientationIsProtrait() -> Bool {
        return UIScreen.main.bounds.width < UIScreen.main.bounds.height
    }
    
    public class func orientationChanged(to: UIInterfaceOrientation) {
        UIDevice.current.setValue(to.rawValue, forKey: "orientation")
        UIApplication.shared.statusBarOrientation = to
    }
    
    // MARK: - 弹出确认信息
    
    public class func alert(sure controller: UIViewController, title: String?, sure: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let block = UIAlertAction(title: "确认", style: .default) { (alert) in
            sure()
        }
        let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(block)
        alertController.addAction(cancel)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    public class func alert(choice controller: UIViewController, title: String?, sure: ((UIAlertAction) -> Void)?, cancel: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let sure = UIAlertAction(title: "确认", style: UIAlertActionStyle.default, handler: sure)
        let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: cancel)
        alertController.addAction(sure)
        alertController.addAction(cancel)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    public class func alert(warning controller: UIViewController, title: String?, sure: ((UIAlertAction) -> Void)?, cancel: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let sure = UIAlertAction(title: "确认", style: UIAlertActionStyle.default, handler: sure)
        alertController.addAction(sure)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - 文本高度
    
    public class func textSize(text: String, forFont: UIFont, width: CGFloat) -> CGSize {
        let text = NSString(string: text)
        let constraint = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let box = text.boundingRect(with: constraint, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: forFont], context: nil)
        return box.size
    }
    
}

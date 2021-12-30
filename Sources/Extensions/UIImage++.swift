//
//  UIImage++.swift
//

import UIKit

public extension UIImage {
    
    func scaled(to newSize: CGSize = CGSize(width: 32, height: 32)) -> UIImage? {
        let type = self
        let imageAspectRatio = type.size.width / type.size.height
        let canvasAspectRatio = newSize.width / newSize.height

        var resizeFactor: CGFloat

        if imageAspectRatio > canvasAspectRatio {
            resizeFactor = newSize.width / type.size.width
        } else {
            resizeFactor = newSize.height / type.size.height
        }

        let scaledSize = CGSize(width: type.size.width * resizeFactor, height: type.size.height * resizeFactor)
        let origin = CGPoint(x: (newSize.width - scaledSize.width) / 2.0, y: (newSize.height - scaledSize.height) / 2.0)

        UIGraphicsBeginImageContextWithOptions(newSize, false, type.scale)
        type.draw(in: CGRect(origin: origin, size: scaledSize))

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext() ?? type
        UIGraphicsEndImageContext()

        return scaledImage
    }
    
    func compress(compressionQuality: CGFloat = 0.5, newSize: CGSize = CGSize(width: 640.0, height: 1136.0)) -> UIImage? {
        // Reducing file size to a 10th
        var actualHeight: CGFloat = self.size.height
        var actualWidth: CGFloat = self.size.width
        let maxHeight: CGFloat = 1136.0
        let maxWidth: CGFloat = 640.0
        var imgRatio: CGFloat = actualWidth/actualHeight
        let maxRatio: CGFloat = maxWidth/maxHeight
        var compressionQuality: CGFloat = 0.5
        
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            } else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            } else {
                actualHeight = maxHeight
                actualWidth = maxWidth
                compressionQuality = 1
            }
        }
        let rect = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
        UIGraphicsBeginImageContext(rect.size)
        self.draw(in: rect)
        guard let img = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()
        guard let imageData = img.jpegData(compressionQuality: compressionQuality) else {
            return nil
        }
        return UIImage(data: imageData)
    }
    
    func toString() -> String {
        return self.jpegData(compressionQuality: 1.0)!.base64EncodedString(options: [])
    }
}

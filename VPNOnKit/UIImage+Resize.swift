//
//  UIImage+Resize.swift
//  VPNOnKit
//
//  Created by Lex on 2019/8/17.
//  Copyright © 2019 LexTang.com. All rights reserved.
//

import UIKit

public extension UIImage {
    func resize(newSize: CGSize) -> UIImage {
        let newRect = CGRect(origin: CGPoint.zero, size: newSize).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext(), let cgImage = cgImage else {
            return self
        }
        
        context.interpolationQuality = CGInterpolationQuality.default
        context.draw(cgImage, in: newRect)
        
        guard let newImageRef = context.makeImage() else {
            return self
        }
        let newImage = UIImage(cgImage: newImageRef, scale: UIScreen.main.scale, orientation: self.imageOrientation)
        UIGraphicsEndImageContext()
        
        return newImage
    }

}

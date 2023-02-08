//
//  UIImage+.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/02.
//

import UIKit

extension UIImage {
    
    static let dayengBackground = UIImage(named: "paperBackground")
    static let dayengLogo = UIImage(named: "LogoImage")
    
    /// 입력한 width, height로 이미지 리사이즈
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    /// 사진 비율 유지하며 resizing
    func resized(scaledToWidth newWidth: CGFloat) -> UIImage? {
        let oldWidth = size.width
        let scaleFactor = newWidth / oldWidth
        let newHeight = size.height * scaleFactor
        
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        self.draw(in: CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

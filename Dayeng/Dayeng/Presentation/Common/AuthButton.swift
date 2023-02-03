//
//  AuthButton.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/01.
//

import UIKit

final class AuthButton: UIButton {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(type: AuthType) {
        super.init(frame: CGRect.zero)
        
        self.setTitle(type.loginMessage, for: .normal)
        self.setImage(type.logoImage, for: .normal)
        self.backgroundColor = type.backgroundColor
        self.tintColor = .black
        self.setTitleColor(.black, for: .normal)
        self.layer.cornerRadius = 7
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 0.5
        self.imageView?.contentMode = .scaleAspectFit
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = type.backgroundColor
            config.baseForegroundColor = .black
            config.imagePadding = 5
            self.configuration = config
        } else {
            self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -5)
            self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
            self.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
    }
}

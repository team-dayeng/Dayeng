//
//  AuthButton.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/01.
//

import UIKit

class AuthButton: UIButton {
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
        self.layer.cornerRadius = 5
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
        
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        self.contentMode = .scaleToFill
//        self.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

    }
}

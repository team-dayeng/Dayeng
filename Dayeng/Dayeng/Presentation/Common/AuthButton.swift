//
//  AuthButton.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/01.
//

import UIKit
import SnapKit

final class AuthButton: UIButton {
    
    private var logoImageView: UIImageView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(type: AuthType) {
        super.init(frame: CGRect.zero)
        configureUI(type)
    }
    
    private func configureUI(_ type: AuthType) {
        
        self.setTitle(type.loginMessage, for: .normal)
        self.setTitleColor(.black, for: .normal)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        self.tintColor = .black
        self.backgroundColor = type.backgroundColor
        
        self.layer.cornerRadius = 7
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 0.5
        self.layer.shadowOpacity = 1.0
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowRadius = 2
        
        logoImageView = UIImageView(image: type.logoImage)
        self.addSubview(logoImageView)
        logoImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(15)
            $0.width.height.equalTo(18)
        }
        logoImageView.contentMode = .scaleAspectFill
    }
}

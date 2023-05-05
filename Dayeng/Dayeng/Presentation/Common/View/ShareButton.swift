//
//  ShareButton.swift
//  Dayeng
//
//  Created by 배남석 on 2023/05/05.
//

import UIKit

final class ShareButton: UIButton {
    private var logoImageView: UIImageView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(type: ShareType) {
        super.init(frame: CGRect.zero)
        configureUI(type)
    }
    
    private func configureUI(_ type: AuthType) {
        
        self.setTitle(type.shareMessage, for: .normal)
        self.setTitleColor(.black, for: .normal)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        self.tintColor = .black
        self.backgroundColor = type.backgroundColor
        self.layer.cornerRadius = 8
        self.titleLabel?.font = .systemFont(ofSize: 20)
        
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

//
//  UIView+.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/27.
//

import UIKit

extension UIView {
    func addBackgroundImage() {
        let backgroundImage = UIImageView(image: UIImage.dayengBackground)
        addSubview(backgroundImage)
        backgroundImage.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

//
//  UITextfield+.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/05/06.
//

import UIKit

extension UITextField {
    func addLeftPadding() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}

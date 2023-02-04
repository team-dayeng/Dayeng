//
//  UIViewController+.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/04.
//

import UIKit

extension UIViewController {
    func showAlert(
        title: String,
        message: String? = nil,
        leftActionTitle: String = "취소",
        rightActionTitle: String = "확인",
        leftActionHandler: (() -> Void)? = nil,
        rightActionHandler: (() -> Void)? = nil
    ) {
        let alertViewController = DayengAlertViewController(
            title: title,
            message: message,
            leftActionTitle: leftActionTitle,
            rightActionTitle: rightActionTitle)
        
        present(alertViewController, animated: false)
    }
    
    private func showAlert(
        _ alertViewController: DayengAlertViewController,
        leftActionHandler: (() -> Void)? = nil,
        rightActionHandler: (() -> Void)? = nil
    ) {
        if let leftActionHandler {
            alertViewController.setLeftButtonAction {
                alertViewController.dismiss(
                    animated: false,
                    completion: leftActionHandler
                )
            }
        }
        if let rightActionHandler {
            alertViewController.setRightButtonAction() {
                alertViewController.dismiss(
                    animated: false,
                    completion: rightActionHandler
                )
            }
        }
        present(alertViewController, animated: false)
    }
}

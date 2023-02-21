//
//  UIViewController+.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/04.
//

import UIKit

extension UIViewController {
    
    func showIndicator() {
        let indicator = IndicatorView(frame: CGRect(x: 0,
                                                    y: 0,
                                                    width: view.frame.width,
                                                    height: view.frame.height))
        
        navigationController?.view.addSubview(indicator)
        indicator.start()
    }
    
    func hideIndicator() {
        if let navigationController = navigationController {
            let indicators = navigationController.view.subviews
                .filter { $0 is IndicatorView }
                .map {$0 as? IndicatorView }
            indicators.forEach {
                $0?.stop()
                $0?.removeFromSuperview()
            }
        }
    }
    
    func addBackgroundImage() {
        let backgroundImage = UIImageView(image: UIImage.dayengBackground)
        view.addSubview(backgroundImage)
        backgroundImage.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func showAlert(
        title: String,
        message: String? = nil,
        type: AlertType,
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
        
        showAlert(alertViewController,
                  type: type,
                  leftActionHandler: leftActionHandler,
                  rightActionHandler: rightActionHandler)
    }
    
    private func showAlert(
        _ alertViewController: DayengAlertViewController,
        type: AlertType,
        leftActionHandler: (() -> Void)? = nil,
        rightActionHandler: (() -> Void)? = nil
    ) {
        if type == .twoButton {
            alertViewController.setLeftButtonAction {
                alertViewController.dismiss(
                    animated: false,
                    completion: leftActionHandler
                )
            }
        }
        alertViewController.setRightButtonAction {
            alertViewController.dismiss(
                animated: false,
                completion: rightActionHandler
            )
        }
        present(alertViewController, animated: false)
    }
}

//
//  UIViewController+.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/04.
//

import UIKit
import RxSwift
import RxCocoa

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
                .map { $0 as? IndicatorView }
            indicators.forEach {
                $0?.stop()
                $0?.removeFromSuperview()
            }
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
    
    func showToast(type: ToastType) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75,
                                               y: self.view.frame.size.height-100,
                                               width: 150,
                                               height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = .systemFont(ofSize: 12)
        toastLabel.textAlignment = .center
        toastLabel.text = type.title
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 2.5, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }
}

public extension Reactive where Base: UIViewController {
    var viewDidLoad: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewDidLoad)).map { _ in }
        return ControlEvent(events: source)
    }
    
    var viewWillAppear: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewWillAppear(_:))).map { _ in }
        return ControlEvent(events: source)
    }
}

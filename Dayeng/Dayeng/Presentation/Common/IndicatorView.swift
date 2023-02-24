//
//  IndicatorView.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/08.
//

import UIKit

class IndicatorView: UIView {
    // MARK: - UI properties
    lazy var indicator: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.style = .large
        activityIndicatorView.center = center
        return activityIndicatorView
    }()
    // MARK: - Properties
    
    // MARK: - Lifecycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white.withAlphaComponent(0.5)
        addSubview(indicator)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Helpers
    func start() {
        indicator.startAnimating()
    }
    
    func stop() {
        indicator.stopAnimating()
    }
}

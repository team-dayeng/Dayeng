//
//  DayengAlertViewController.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/04.
//

import UIKit
import SnapKit

final class DayengAlertViewController: UIViewController {
    
    // MARK: - UI properties
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "타이틀"
        return label
    }()
    
    private var messageLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "메시지"
        return label
    }()
    
    private lazy var buttonStackView: UIStackView = {
        var stackView = UIStackView()
        stackView.spacing = 10
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var rightButton: UIButton = {
        var button = UIButton()
        button.backgroundColor = .dayengMain
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.layer.cornerRadius = 10
        return button
    }()
    
    private lazy var leftButton: UIButton = {
        var button = UIButton()
        button.backgroundColor = UIColor(hexString: "F0F0F0")
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.layer.cornerRadius = 10
        return button
    }()
    
    // MARK: - Lifecycles
    init(title: String,
         message: String? = nil,
         leftActionTitle: String,
         rightActionTitle: String
    ) {
        super.init(nibName: nil, bundle: nil)
        
        titleLabel.text = title
        messageLabel.text = message
        leftButton.setTitle(leftActionTitle, for: .normal)
        rightButton.setTitle(rightActionTitle, for: .normal)
        
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        configureUI()
    }
    
    // MARK: - Helpers
    private func setupViews() {
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(rightButton)
    }
    
    private func configureUI() {
        view.backgroundColor = .gray.withAlphaComponent(0.8)
        
        containerView.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-2)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.greaterThanOrEqualTo(150)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(35)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.greaterThanOrEqualTo(24)
        }
        
        messageLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(titleLabel)
            $0.height.greaterThanOrEqualTo(0)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(messageLabel.snp.bottom).offset(40)
            $0.bottom.equalToSuperview().inset(20)
            $0.leading.trailing.equalTo(titleLabel)
            $0.height.equalTo(50)
        }
    }
    
    func setRightButtonAction(handler: (() -> Void)? = nil) {
        rightButton.addAction(
            UIAction(handler: { _ in handler?() }),
            for: .touchUpInside
        )
        buttonStackView.addArrangedSubview(rightButton)
    }
    
    func setLeftButtonAction(handler: (() -> Void)? = nil) {
        leftButton.addAction(
            UIAction(handler: { _ in handler?() }),
            for: .touchUpInside
        )
        buttonStackView.addArrangedSubview(leftButton)
    }
}

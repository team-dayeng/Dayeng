//
//  AddFriendViewController.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/04.
//

import UIKit

final class AddFriendViewController: UIViewController {
    // MARK: - UI properties
    private lazy var backgroundImage: UIImageView = {
        var imageView: UIImageView = UIImageView()
        imageView.image = UIImage(named: "paperBackground")
        
        return imageView
    }()
    
    private lazy var introductionLabel: UILabel = {
        var label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        label.text = "친구를 맺어,\n일기를 공유해보세요"
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var logoImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(named: "LogoImage")
        return imageView
    }()
    
    private lazy var codeButton: UIButton = {
        var button = UIButton()
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 71/255, green: 71/255, blue: 71/255, alpha: 1),
            .underlineStyle: NSUnderlineStyle.thick.rawValue,
            .font: UIFont.boldSystemFont(ofSize: 20)
        ]
        let attributedString = NSAttributedString(string: "1q2w3e4r", attributes: attributes)
        button.setAttributedTitle(attributedString, for: .normal)
        return button
    }()
    
    private lazy var copyButton: UIButton = {
        var button = UIButton()
        button.setTitle("복사하기", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        var button = UIButton()
        button.setTitle("공유하기", for: .normal)
        button.tintColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.setTitleColor(.black, for: .normal)
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        button.semanticContentAttribute = .forceRightToLeft
        button.layer.cornerRadius = 8
        return button
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var codeTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 20)
        textField.placeholder = "  코드 입력"
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 8
        return textField
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setTitle("추가하기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.layer.cornerRadius = 8
        return button
    }()
    // MARK: - Properties
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "친구 추가"
        setupViews()
        configureUI()
    }
    // MARK: - Helpers
    private func setupViews() {
        [backgroundImage,
         introductionLabel,
         logoImageView,
         codeButton,
         copyButton,
         shareButton,
         separatorView,
         codeTextField,
         addButton].forEach {
            view.addSubview($0)
        }
    }
    private func configureUI() {
        let heightRatio = view.frame.height / 852
        let widthRatio = view.frame.width / 393
        
        backgroundImage.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(-50)
            $0.top.bottom.equalToSuperview().inset(-100)
        }
        introductionLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(180*heightRatio)
            $0.centerX.equalToSuperview()
        }
        logoImageView.snp.makeConstraints {
            $0.top.equalTo(introductionLabel.snp.bottom).offset(12)
            $0.height.equalTo(149*heightRatio)
            $0.width.equalTo(295*heightRatio)
            $0.centerX.equalToSuperview()
        }
        codeButton.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(5)
            $0.height.equalTo(50*heightRatio)
            $0.centerX.equalToSuperview()
        }
        copyButton.snp.makeConstraints {
            $0.top.equalTo(codeButton.snp.bottom)
            $0.centerX.equalToSuperview()
        }
        shareButton.snp.makeConstraints {
            $0.top.equalTo(copyButton.snp.bottom).offset(20*heightRatio)
            $0.height.equalTo(50*heightRatio)
            $0.width.equalTo(262*widthRatio)
            $0.centerX.equalToSuperview()
        }
        separatorView.snp.makeConstraints {
            $0.top.equalTo(shareButton.snp.bottom).offset(40*heightRatio)
            $0.height.equalTo(1)
            $0.width.equalTo(shareButton)
            $0.centerX.equalToSuperview()
        }
        codeTextField.snp.makeConstraints {
            $0.top.equalTo(separatorView.snp.bottom).offset(40*heightRatio)
            $0.height.equalTo(50*heightRatio)
            $0.width.equalTo(shareButton)
            $0.centerX.equalToSuperview()
        }
        addButton.snp.makeConstraints {
            $0.top.equalTo(codeTextField.snp.bottom).offset(20*heightRatio)
            $0.height.equalTo(50*heightRatio)
            $0.width.equalTo(shareButton)
            $0.centerX.equalToSuperview()
        }
    }
}

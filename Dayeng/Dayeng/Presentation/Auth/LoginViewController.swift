//
//  LoginViewController.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/01.
//

import UIKit
import AuthenticationServices

class LoginViewController: UIViewController {
    
    // MARK: - UI properties
    private lazy var backgroundImage: UIImageView = {
        var imageView: UIImageView = UIImageView()
        imageView.image = UIImage(named: "paperBackground")
        return imageView
    }()
    
    private lazy var logoImage: UIImageView = {
        var imageView: UIImageView = UIImageView()
        imageView.image = UIImage(named: "LogoImage")
        return imageView
    }()
    
//    private var appleLoginButton = AuthButton(type: .apple)
    private var appleLoginButton = ASAuthorizationAppleIDButton(
        type: .signIn,
        style: .whiteOutline
    )
    private var kakaoLoginButton = AuthButton(type: .kakao)
    
    // MARK: - Properties
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.addSubview(backgroundImage)
        view.addSubview(logoImage)
        view.addSubview(appleLoginButton)
        view.addSubview(kakaoLoginButton)
        backgroundImage.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        logoImage.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(50)
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-130)
            $0.height.equalTo(150)
        }
        appleLoginButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(130)
            $0.leading.trailing.equalToSuperview().inset(60)
            $0.height.equalTo(45)
        }
        kakaoLoginButton.snp.makeConstraints {
            $0.top.equalTo(appleLoginButton.snp.bottom).offset(15)
            $0.centerX.height.leading.trailing.equalTo(appleLoginButton)
        }
    }
}

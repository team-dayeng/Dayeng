//
//  LoginViewController.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/01.
//

import UIKit
import AuthenticationServices
import RxSwift
import RxCocoa

@available(iOS 13.0, *)     // Apple 로그인은 iOS 13.0 버전 이후부터 지원
final class LoginViewController: UIViewController {
    
    // MARK: - UI properties
    private lazy var backgroundImage: UIImageView = {
        var imageView: UIImageView = UIImageView()
        imageView.image = UIImage(named: "paperBackground")
        return imageView
    }()
    
    private lazy var logoImage: UIImageView = {
        var imageView: UIImageView = UIImageView()
        imageView.image = .dayengLogo
        return imageView
    }()

    private var appleLoginButton = AuthButton(type: .apple)
    private var kakaoLoginButton = AuthButton(type: .kakao)
    
    // MARK: - Properties
//    private let viewModel: LoginViewModel
    
    // MARK: - Lifecycles
//    init(viewModel: LoginViewModel) {
//        self.viewModel = viewModel
//        super.init()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        configureUI()
        setup()
        bind()
    }
    
    // MARK: - Helpers
    
    private func setupViews() {
        view.addSubview(backgroundImage)
        view.addSubview(logoImage)
        view.addSubview(appleLoginButton)
        view.addSubview(kakaoLoginButton)
    }
    
    private func configureUI() {
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
            $0.height.equalTo(50)
        }
        kakaoLoginButton.snp.makeConstraints {
            $0.top.equalTo(appleLoginButton.snp.bottom).offset(15)
            $0.centerX.height.leading.trailing.equalTo(appleLoginButton)
        }
    }
    
    private func setup() {
        setupAppleLogin()
    }
    private func bind() {
        // TODO: rx delegate proxy
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    private func setupAppleLogin() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(
            authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    /// Apple 로그인 텍스트 프로바이딩
    /// 애플 로그인 버튼을 눌렀을 때 애플 로그인을 modal sheet로 표시해주는 함수
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    /// apple ID 연동 성공시
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            // get user info
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            print("user ID: \(userIdentifier)")
            print("user Name: \(fullName)")
            print("user email: \(email)")
        default:
            break
        }
    }
    
    /// apple ID 연동 실패시
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // TODO: 개발자 계정 승인 후 signing에서 sign in with apple 추가
        // TODO: error handling
        print("AppleID Credential failed with error: \(error.localizedDescription)")
    }
}

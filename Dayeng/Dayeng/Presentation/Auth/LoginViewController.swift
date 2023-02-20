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
import CryptoKit
import FirebaseAuth

@available(iOS 13.0, *)     // Apple 로그인은 iOS 13.0 버전 이후부터 지원
final class LoginViewController: UIViewController {
    
    // MARK: - UI properties
    private lazy var logoImage: UIImageView = {
        var imageView: UIImageView = UIImageView()
        imageView.image = .dayengLogo
        return imageView
    }()

    private var appleLoginButton = AuthButton(type: .apple)
//    private var appleLoginButton = ASAuthorizationAppleIDButton(type: .signIn, style: .whiteOutline)
    private var kakaoLoginButton = AuthButton(type: .kakao)
    
    // MARK: - Properties
//    private let viewModel: LoginViewModel
    private var disposeBag = DisposeBag()
    var currentNonce: String?
    
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
        bind()
        
        // 임시: log out
        do {
            try Auth.auth().signOut()
        } catch {
            print("sign out error: \(error)")
        }
    }
    
    // MARK: - Helpers
    
    private func setupViews() {
        addBackgroundImage()
        view.addSubview(logoImage)
        view.addSubview(appleLoginButton)
        view.addSubview(kakaoLoginButton)
    }
    
    private func configureUI() {
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

    private func bind() {
        
        appleLoginButton.rx.tap
            .asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.startSignInWithAppleFlow()
            })
            .disposed(by: disposeBag)

    }
    
    func startSignInWithAppleFlow() {
        
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.rx.login(
            scope: [.fullName, .email],
            on: view.window!,
            nonce: sha256(nonce)
        )
        .subscribe(onNext: { [weak self] authorization in
            
            guard let self else { return }
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = self.currentNonce else {
                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("Unable to fetch identity token")
                    return
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                    return
                }
                
                // Initialize a Firebase credential.
                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: nonce)
                
                // Sign in with Firebase.
                Auth.auth().signIn(with: credential) { (authResult, error) in
                    if let error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    let rep = DefaultUserRepository(firestoreService: DefaultFirestoreDatabaseService())
                    guard let uid = Auth.auth().currentUser?.uid,
                          let familyName = appleIDCredential.fullName?.familyName,
                          let givenName = appleIDCredential.fullName?.givenName else {
                        return
                    }
                    let fullName = familyName + givenName
                    rep.uploadUser(user: User(uid: uid, name: fullName))
                        .subscribe {
                            print($0)
                        }
                        .disposed(by: self.disposeBag)
                }
            }
        }, onError: { error in
            // TODO: error handling
            print("AppleID Credential failed with error: \(error.localizedDescription)")
        })
        .disposed(by: disposeBag)
    }
}

extension LoginViewController {
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

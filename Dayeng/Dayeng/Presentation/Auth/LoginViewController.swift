//
//  LoginViewController.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/01.
//

import UIKit
import RxSwift
import RxCocoa

final class LoginViewController: UIViewController {
    
    // MARK: - UI properties
    
    private lazy var logoImage: UIImageView = {
        var imageView: UIImageView = UIImageView()
        imageView.image = .dayengLogo
        return imageView
    }()

    private var appleLoginButton = AuthButton(type: .apple)
    private var kakaoLoginButton = AuthButton(type: .kakao)
    
    // MARK: - Properties
    
    private let viewModel: LoginViewModel
    private var disposeBag = DisposeBag()
    
    // MARK: - Lifecycles
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        configureUI()
        bind()
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
        let input = LoginViewModel.Input(
            appleLoginButtonDidTap: appleLoginButton.rx.tap.asObservable(),
            kakaoLoginButtonDidTap: kakaoLoginButton.rx.tap.asObservable()
        )
        _ = viewModel.transform(input: input)
        
        Observable.merge(appleLoginButton.rx.tap.asObservable(), kakaoLoginButton.rx.tap.asObservable())
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.showIndicator()
            })
            .disposed(by: disposeBag)
    }
}

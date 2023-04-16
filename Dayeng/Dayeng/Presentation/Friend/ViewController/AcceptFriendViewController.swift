//
//  AcceptFriendViewController.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/04.
//

import UIKit
import RxSwift
import SnapKit

final class AcceptFriendViewController: UIViewController {
    // MARK: - UI properties
    private lazy var introductionLabel: UILabel = {
        var label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        label.text = "친구추가 요청이 왔어요"
        return label
    }()
    
    private lazy var logoImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.image = .dayengLogo
        return imageView
    }()
    
    private lazy var shareLabel: UILabel = {
        var label = UILabel()
        label.text = "\(acceptFriendName) 님과 dayeng을\n공유해보세요"
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20)
        return label
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
    
    private lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "multiply"), for: .normal)
        button.tintColor = .dayengMain
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 25), forImageIn: .normal)
        return button
    }()
    
    // MARK: - Properties
    private let viewModel: AcceptFriendViewModel
    private let disposeBag = DisposeBag()
    private let acceptFriendName: String
    
    // MARK: - Lifecycles
    init(viewModel: AcceptFriendViewModel, acceptFriendName: String) {
        self.viewModel = viewModel
        self.acceptFriendName = acceptFriendName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setupViews()
        configureUI()
    }
    
    // MARK: - Helpers
    private func bind() {
        let input = AcceptFriendViewModel.Input(
            addButtonDidTapped: addButton.rx.tap.map { _ in }.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.addFriendResult
            .subscribe(onNext: {
                self.showAlert(title: "친구 등록 성공", type: .oneButton, rightActionHandler: {
                    self.dismiss(animated: true)
                })
            }, onError: { error in
                self.showAlert(title: "친구 등록 실패", message: "\(error)", type: .oneButton, rightActionHandler: {
                    self.dismiss(animated: true)
                })
            })
            .disposed(by: disposeBag)
        
        dismissButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self else { return }
            self.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
    }
    
    private func setupViews() {
        view.addBackgroundImage()
        [introductionLabel, logoImageView, shareLabel, addButton, dismissButton].forEach {
            view.addSubview($0)
        }
    }
    private func configureUI() {
        let heightRatio = view.frame.height / 852
        
        dismissButton.snp.makeConstraints {
            $0.top.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.height.width.equalTo(25)
        }
        
        introductionLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(150*heightRatio)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        logoImageView.snp.makeConstraints {
            $0.top.equalTo(introductionLabel.snp.bottom).offset(30)
            $0.height.equalTo(149*heightRatio)
            $0.width.equalTo(295*heightRatio)
            $0.centerX.equalToSuperview()
        }
        
        shareLabel.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(70*heightRatio)
            $0.centerX.equalToSuperview()
        }
        
        addButton.snp.makeConstraints {
            $0.top.equalTo(shareLabel.snp.bottom).offset(70)
            $0.height.equalTo(50)
            $0.leading.equalToSuperview().offset(66)
            $0.trailing.equalToSuperview().offset(-66)
        }
    }
}

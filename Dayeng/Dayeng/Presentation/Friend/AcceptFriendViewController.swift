//
//  AcceptFriendViewController.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/04.
//

import UIKit

final class AcceptFriendViewController: UIViewController {
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
        label.text = "옹이 님과 dayeng을\n공유해보세요"
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
    // MARK: - Properties
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        configureUI()
    }
    // MARK: - Helpers
    private func setupViews() {
        [backgroundImage, introductionLabel, logoImageView, shareLabel, addButton].forEach {
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
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(200*heightRatio)
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


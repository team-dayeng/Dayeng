//
//  NetworkDisconnectViewController.swift
//  Dayeng
//
//  Created by 배남석 on 2023/03/31.
//

import UIKit
import SnapKit

final class NetworkDisconnectViewController: UIViewController {
    // MARK: - UI properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "네트워크 오류"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.sizeToFit()
        
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "네트워크가 연결되지 않았습니다.\n연결상태를 확인하세요."
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .gray
        label.sizeToFit()
        label.numberOfLines = 0
        
        return label
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
        view.addBackgroundImage()
        
        [titleLabel,
         descriptionLabel
        ].forEach {
            view.addSubview($0)
        }
    }
    
    private func configureUI() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(view.safeAreaLayoutGuide).offset(-25)
            $0.centerX.trailing.leading.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.centerX.trailing.leading.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(15)
        }
    }
}

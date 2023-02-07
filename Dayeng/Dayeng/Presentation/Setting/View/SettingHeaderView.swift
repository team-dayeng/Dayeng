//
//  SettingHeaderView.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/06.
//

import UIKit
import SnapKit

final class SettingHeaderView: UICollectionReusableView {
    // MARK: - UI properties
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .black
        
        return label
    }()
    
    // MARK: - Properties
    static let identifier: String = "SettingHeaderView"
    
    // MARK: - Lifecycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func setupViews() {
        addSubview(titleLabel)
    }
    
    private func configureUI() {
        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().inset(10)
        }
    }
    
    func bind(text: String) {
        titleLabel.text = text
    }
}

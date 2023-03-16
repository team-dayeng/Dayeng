//
//  FriendListCell.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/03.
//

import UIKit
import SnapKit

final class FriendListCell: UICollectionViewCell {
    
    // MARK: - UI properties
    private var nameLabel: UILabel = {
        var label = UILabel()
        label.text = "James Mcavoy"
        label.textColor = .dayengMain
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    private var dayLabel: UILabel = {
        var label = UILabel()
        label.text = "1일째"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    // MARK: - Properties
    static let identifier = "FriendListCell"
    var userInfo: User?
    
    // MARK: - Lifecycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(nameLabel)
        addSubview(dayLabel)
    }
    
    // MARK: - Helpers
    private func configureUI() {
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.black.cgColor
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
        dayLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalTo(nameLabel)
        }
    }
    
    func bind(userInfo: User) {
        self.userInfo = userInfo
        nameLabel.text = userInfo.name
        dayLabel.text = "\(userInfo.currentIndex + 1)일째"
    }
}

//
//  CommonCalendarCell.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/01.
//

import UIKit
import SnapKit

final class CommonCalendarCell: UICollectionViewCell {
    // MARK: - UI properties
    private lazy var numberLabel: UILabel = {
        var label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .center
        
        return label
    }()
    
    private lazy var statusLabel: UILabel = {
        var label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .center
        
        let attributedString = NSMutableAttributedString(string: "")
        
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: "lock")
        imageAttachment.setImageHeight(height: 20)
        
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        
        label.attributedText = attributedString
        return label
    }()
    
    // MARK: - Properties
    static let identifier: String = "CommonCalendarCell"
    
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
        contentView.addSubview(numberLabel)
        contentView.addSubview(statusLabel)
    }
    
    private func configureUI() {
        numberLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(statusLabel.snp.top)
        }
        
        statusLabel.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(25)
        }
    }
    
    func configureNumberLabel(number: Int) {
        numberLabel.text = "\(number)"
    }
    
    func configureStatusLabel() {
        
    }
}

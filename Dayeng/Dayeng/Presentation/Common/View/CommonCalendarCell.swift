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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        statusLabel.attributedText = nil
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
    
    func bind(index: Int, answer: Answer?, currentIndex: Int) {
        numberLabel.text = "\(index + 1)"
        
        if index == currentIndex {
            numberLabel.textColor = .dayengMain
        }
        
        guard let answer else {
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(named: "lock")
            imageAttachment.setImageHeight(height: 20)
            
            let attributedString = NSMutableAttributedString(string: "")
            attributedString.append(NSAttributedString(attachment: imageAttachment))
            statusLabel.attributedText = attributedString
            return
        }
        
        statusLabel.text = fetchDate(answer.date)
        if answer.answer.isEmpty {
            statusLabel.text = "X"
        }
    }
    
    /// "2023.03.16.Thu" 에서 "23.03.16" 만 추출
    private func fetchDate(_ fullDate: String) -> String {
        let startIndex = fullDate.index(fullDate.startIndex, offsetBy: 2)
        let endIndex = fullDate.index(fullDate.startIndex, offsetBy: 9)
        return String(fullDate[startIndex...endIndex])
    }
}

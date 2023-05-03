//
//  AlarmDayCell.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/06.
//

import UIKit
import SnapKit

final class AlarmDayCell: UICollectionViewCell {
    // MARK: - UI properties
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .regular)
        
        return label
    }()
    
    private lazy var isSelectedImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "checkmark")
        view.contentMode = .scaleAspectFill
        view.isHidden = true
        view.tintColor = UIColor(named: "MainColor")
        
        return view
    }()
    
    // MARK: - Properties
    static let identifier: String = "AlarmDayCell"
    var isSelect: Bool
    
    // MARK: - Lifecycles
    override init(frame: CGRect) {
        isSelect = false
        super.init(frame: frame)
        
        setupViews()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func setupViews() {
        contentView.addSubview(dayLabel)
        contentView.addSubview(isSelectedImageView)
    }
    
    private func configureUI() {
        contentView.backgroundColor = .white
        
        dayLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(15)
            $0.top.bottom.equalToSuperview().inset(5)
        }
        
        isSelectedImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(15)
            $0.top.bottom.equalToSuperview().inset(13)
        }
    }
    
    func bind(text: String) {
        dayLabel.text = text
    }
    
    func tappedCell(isSelected: Bool) {
        isSelectedImageView.isHidden = !isSelected
        isSelect = isSelected
    }
}

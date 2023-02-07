//
//  SettingCell.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/06.
//

import UIKit
import SnapKit
import RxSwift
import RxRelay

final class SettingCell: UICollectionViewCell {
    // MARK: - UI properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black
        label.textAlignment = .left
        
        return label
    }()
    
    // MARK: - Properties
    static let identifier: String = "SettingCell"
    var tappedView: Observable<Void>!
    
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
        contentView.addSubview(titleLabel)
    }
    
    private func configureUI() {
        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().inset(10)
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer()
        contentView.addGestureRecognizer(tapGestureRecognizer)
        tappedView = tapGestureRecognizer.rx.event.map {_ in}.asObservable()
    }
    
    func bind(text: String) {
        titleLabel.text = text
    }
}

//
//  MainCell.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/05.
//

import UIKit
import RxSwift

final class MainCell: UICollectionViewCell {
    // MARK: - UI properties
    lazy var mainView = {
       CommonMainView()
    }()
    
    // MARK: - Properties
    static let identifier: String = "MainCell"
    
    // MARK: - Lifecycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        mainView.answerLabel.text = ""
        mainView.answerBackground.isHidden = false
        super.prepareForReuse()
    }
    
    // MARK: - Helpers
    private func setupViews() {
        addSubview(mainView)
        configureUI()
    }
    
    private func configureUI() {
        mainView.backgroundImage.removeFromSuperview()
        mainView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        mainView.dateLabel.snp.updateConstraints {
            $0.top.equalToSuperview().offset(40)
        }
    }
}

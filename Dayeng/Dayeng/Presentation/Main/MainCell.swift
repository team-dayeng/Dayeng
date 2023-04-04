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
    lazy var lockedLabel = {
        let label = UILabel()
        label.text = "질문은 하루에 하나씩 공개됩니다"
        label.font = .systemFont(ofSize: 20)
        label.isHidden = true
        return label
    }()
    
    lazy var lockerView = {
        let imageView = UIImageView(image: UIImage(systemName: "lock"))
        imageView.tintColor = .black
        imageView.isHidden = true
        return imageView
    }()
    
    lazy var blurImageView = {
        let imageView = UIImageView(image: UIImage.mainBlur?.resized(scaledToWidth: frame.width-30))
        imageView.backgroundColor = .white
        imageView.isHidden = true
        imageView.contentMode = .top
        imageView.alpha = 0.6
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        return imageView
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
        mainView.answerLabel.text = nil
        unBlur()
        
        super.prepareForReuse()
    }
    
    // MARK: - Helpers
    private func setupViews() {
        addSubview(mainView)
        addSubview(blurImageView)
        addSubview(lockedLabel)
        addSubview(lockerView)
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
        blurImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.bottom.equalToSuperview().offset(-150)
            $0.leading.trailing.equalToSuperview().inset(15)
        }
        lockedLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(200)
        }
        lockerView.snp.makeConstraints {
            $0.centerX.equalTo(blurImageView)
            $0.top.equalTo(lockedLabel).offset(30)
            $0.width.height.equalTo(70)
        }
    }
    
    func blur() {
        mainView.isHidden = true
        [blurImageView, lockerView, lockedLabel].forEach { $0.isHidden = false }
    }

    func unBlur() {
        mainView.isHidden = false
        [blurImageView, lockerView, lockedLabel].forEach { $0.isHidden = true }
    }

}

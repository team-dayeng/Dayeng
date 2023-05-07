//
//  MainCell.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/05.
//

import UIKit
import RxSwift
import RxRelay

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
    
    lazy var adsImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "video.square"))
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var adsLabel: UILabel = {
        let label = UILabel()
        label.text = "바로 질문 보기"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    lazy var adsContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .dayengGray
        view.layer.cornerRadius = 8
        view.isHidden = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        return view
    }()
    
    lazy var blurView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = 20
        imageView.alpha = 0.6
        imageView.isHidden = true
        return imageView
    }()
    
    // MARK: - Properties
    static let identifier: String = "MainCell"
    var disposeBag = DisposeBag()
    
    // MARK: - Lifecycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
        mainView.answerLabel.text = nil
        unBlur()
        
        super.prepareForReuse()
    }
    
    // MARK: - Helpers
    private func setupViews() {
        addSubview(mainView)
        addSubview(blurView)
        addSubview(lockedLabel)
        addSubview(lockerView)
        addSubview(adsContentView)
        [adsImageView, adsLabel].forEach { adsContentView.addSubview($0) }
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
        blurView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.bottom.equalToSuperview().offset(-150)
            $0.leading.trailing.equalToSuperview().inset(15)
        }
        lockedLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(200)
        }
        lockerView.snp.makeConstraints {
            $0.centerX.equalTo(blurView)
            $0.top.equalTo(lockedLabel).offset(30)
            $0.width.height.equalTo(70)
        }
        
        adsContentView.snp.makeConstraints {
            $0.bottom.equalTo(blurView.snp.bottom).offset(-50)
            $0.leading.trailing.equalTo(blurView).inset(50)
            $0.height.equalTo(70)
        }
        
        adsImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(10)
            $0.width.height.equalTo(60)
        }
        
        adsLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(adsImageView.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().offset(-10)
        }
    }
    
    func setupAds() {
        adsContentView.isHidden = false
    }
    
    func blur() {
        if blurView.image != nil {
            [blurView, lockerView, lockedLabel].forEach { $0.isHidden = false }
            mainView.isHidden = true
            return
        }
        
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let uiImage = renderer.image(actions: { context in
            layer.render(in: context.cgContext)
        })
        
        guard let ciImage = CIImage(image: uiImage),
              let blurFilter = CIFilter(name: "CIGaussianBlur") else { return }

        blurFilter.setValue(9, forKey: kCIInputRadiusKey)
        blurFilter.setValue(ciImage, forKey: kCIInputImageKey)

        guard let blurredImage = blurFilter.outputImage else { return }

        blurView.image = UIImage(ciImage: blurredImage)
        [blurView, lockerView, lockedLabel].forEach { $0.isHidden = false }
        mainView.isHidden = true
    }

    func unBlur() {
        mainView.isHidden = false
        [blurView, lockerView, lockedLabel, adsContentView].forEach { $0.isHidden = true }
    }
}

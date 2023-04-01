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
    
    lazy var blurView = {
        let view = UIImageView()
        view.backgroundColor = .white
        view.isHidden = true
        view.layer.cornerRadius = 20
        view.alpha = 0.6
        view.contentMode = .topLeft
        return view
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
        blurView.isHidden = true
        mainView.isHidden = false
        lockedLabel.isHidden = true
        
        super.prepareForReuse()
    }
    
    // MARK: - Helpers
    private func setupViews() {
        addSubview(mainView)
        addSubview(blurView)
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
        blurView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.left.right.equalToSuperview().inset(15)
            $0.bottom.equalToSuperview().offset(-150)
        }
        lockedLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(200)
        }
        lockerView.snp.makeConstraints {
            $0.center.equalTo(blurView)
            $0.width.height.equalTo(70)
        }
    }
    
    func blur() {
        UIGraphicsBeginImageContext(CGSize(width: bounds.size.height - 165,
                                           height: bounds.size.width - 30))
        layer.render(in: UIGraphicsGetCurrentContext()!)
        guard let image = UIGraphicsGetImageFromCurrentImageContext(),
              let blurFilter = CIFilter(name: "CIGaussianBlur") else {
            UIGraphicsEndImageContext()
            return
        }
        UIGraphicsEndImageContext()

        blurFilter.setValue(3, forKey: kCIInputRadiusKey)
        blurFilter.setValue(CIImage(image: image), forKey: kCIInputImageKey)
        
        guard let blurredImage = blurFilter.outputImage,
              let cgImage = CIContext().createCGImage(blurredImage, from: blurredImage.extent) else { return }
        blurView.image = UIImage(cgImage: cgImage)
        blurView.backgroundColor = .white
        blurView.isHidden = false
        mainView.isHidden = true
        lockedLabel.isHidden = false
        lockerView.isHidden = false
    }
}

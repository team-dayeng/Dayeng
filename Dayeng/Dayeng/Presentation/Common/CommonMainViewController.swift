//
//  CommonMainViewController.swift
//  Dayeng
//
//  Created by 조승기 on 2023/01/30.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

class CommonMainViewController: UIViewController {
    // MARK: - UI properties
    lazy var backgroundImage: UIImageView = {
        var imageView: UIImageView = UIImageView()
        imageView.image = UIImage(named: "background")
        return imageView
    }()
    
    lazy var dateLabel: UILabel = {
        var label: UILabel = UILabel()
        label.font = UIFont(name: "HoeflerText-Regular", size: 14)
        label.text = Date().convertToString(format: "yyyy.MM.dd.E")
        return label
    }()
    
    lazy var questionLabel: UILabel = {
        var label: UILabel = UILabel()
        label.font = UIFont(name: "HoeflerText-Black", size: 21)
        label.text = "Q1. where do you want to live? where do you want to live  "
        label.numberOfLines = 0
        return label
    }()
    lazy var koreanQuestionLabel: UILabel = {
        var label: UILabel = UILabel()
        label.font = UIFont(name: "Chalkboard SE", size: 15)
        label.textColor = .gray
        label.text = "어디에 살고 싶나요?"
        return label
    }()
    
    lazy var answerBackground: UITextView = {
        var label: UITextView = UITextView()
        label.backgroundColor = UIColor(white: 1, alpha: 0.5)
        label.layer.cornerRadius = 20
        label.font = UIFont(name: "HoeflerText-Regular", size: 21)
        label.text = " A1."
        label.textColor = .lightGray
        label.isEditable = false
        return label
    }()
    
    lazy var answerLabel: UILabel = {
        var label: UILabel = UILabel()
        label.font = UIFont(name: "HoeflerText-Regular", size: 17)
        label.text = ""
        return label
    }()
    
    // MARK: - Properties
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        configureUI()
    }
    // MARK: - Helpers
    private func setupViews() {
        [backgroundImage,
         dateLabel,
         questionLabel,
         koreanQuestionLabel,
         answerBackground,
         answerLabel
        ].forEach {
            view.addSubview($0)
        }
    }
    private func configureUI() {
        navigationItem.titleView = UIImageView(image: UIImage(named: "LogoImage"))
        navigationController?.navigationBar.tintColor = .black
        
        backgroundImage.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(120)
            $0.left.right.equalToSuperview().inset(20)
        }
        
        questionLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(10)
            $0.left.right.equalTo(dateLabel)
        }
        
        koreanQuestionLabel.snp.makeConstraints {
            $0.top.equalTo(questionLabel.snp.bottom).offset(0)
            $0.left.right.equalTo(dateLabel)
        }
        
        answerBackground.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(20)
            $0.top.equalTo(koreanQuestionLabel.snp.bottom).offset(30)
            $0.bottom.equalTo(view.snp.centerY).offset(30)
        }
        
        answerLabel.snp.makeConstraints {
            $0.top.equalTo(koreanQuestionLabel.snp.bottom).offset(40)
            $0.left.right.equalTo(dateLabel)
        }
    }
}

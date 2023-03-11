//
//  CommonMainView.swift
//  Dayeng
//
//  Created by 조승기 on 2023/01/30.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

final class CommonMainView: UIView {
    // MARK: - UI properties
    lazy var backgroundImage: UIImageView = {
        var imageView: UIImageView = UIImageView()
        imageView.image = UIImage(named: "paperBackground")
        return imageView
    }()
    
    lazy var dateLabel: UILabel = {
        var label: UILabel = UILabel()
        label.font = UIFont(name: "HoeflerText-Regular", size: 15)
        label.text = Date().convertToString(format: "yyyy.MM.dd.E")
        return label
    }()
    
    lazy var questionLabel: UILabel = {
        var label: UILabel = UILabel()
        label.font = UIFont(name: "HoeflerText-Black", size: 22)
        label.text = "Q1. where do you want to live? where do you want to live  "
        label.numberOfLines = 0
        return label
    }()
    
    lazy var koreanQuestionLabel: UILabel = {
        var label: UILabel = UILabel()
        label.font = UIFont(name: "Chalkboard SE", size: 16)
        label.textColor = .gray
        label.text = "어디에 살고 싶나요?"
        return label
    }()
    
    lazy var answerBackground: UITextView = {
        var label: UITextView = UITextView()
        label.backgroundColor = UIColor(white: 1, alpha: 0.5)
        label.layer.cornerRadius = 20
        label.font = UIFont(name: "HoeflerText-Regular", size: 22)
        label.text = " A1."
        label.textColor = .lightGray
        label.isEditable = false
        label.isSelectable = false
        let tapGestureRecognizer = UITapGestureRecognizer()
        label.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.rx.event.map { _ in }.bind(to: editButtonDidTapped).disposed(by: disposeBag)
        return label
    }()
    
    lazy var answerLabel: UILabel = {
        var label: UILabel = UILabel()
        label.font = UIFont(name: "HoeflerText-Regular", size: 19)
        label.text = ""
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer()
        label.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.rx.event.map { _ in }.bind(to: editButtonDidTapped).disposed(by: disposeBag)
        return label
    }()
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    let editButtonDidTapped = PublishRelay<Void>()
    
    // MARK: - Lifecycles
    init() {
        super.init(frame: CGRect())
        setupViews()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            addSubview($0)
        }
    }
    private func configureUI() {
        backgroundImage.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(150)
            $0.left.right.equalToSuperview().inset(20)
        }
        
        questionLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(15)
            $0.left.right.equalTo(dateLabel)
        }
        
        koreanQuestionLabel.snp.makeConstraints {
            $0.top.equalTo(questionLabel.snp.bottom)
            $0.left.right.equalTo(dateLabel)
        }
        
        answerBackground.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(20)
            $0.top.equalTo(koreanQuestionLabel.snp.bottom).offset(35)
            $0.bottom.equalTo(snp.centerY).offset(60)
        }
        
        answerLabel.snp.makeConstraints {
            $0.top.equalTo(koreanQuestionLabel.snp.bottom).offset(60)
            $0.left.right.equalTo(dateLabel)
        }
    }
    
    func bindQuestion(_ question: Question) {
        questionLabel.text = question.english
        koreanQuestionLabel.text = question.korean
    }
    
    func bindAnswer(_ answer: Answer) {
        dateLabel.text = answer.date
        answerLabel.text = answer.answer
        answerBackground.isHidden = answer.answer.count > 0
    }
}

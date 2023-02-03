//
//  MainEditViewController.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/03.
//

import UIKit
import RxSwift
import RxCocoa

class MainEditViewController: CommonMainViewController {
    // MARK: - UI properties
    private lazy var answerTextView: UITextView = {
        var textView: UITextView = UITextView()
        textView.backgroundColor = .clear
        textView.font = UIFont(name: "HoeflerText-Regular", size: 17)
        textView.textColor = .lightGray
        textView.text = "enter your answer."
        textView.isScrollEnabled = false
        return textView
    }()
    
    private lazy var textCountLabel = {
        var label: UILabel = UILabel()
        label.font = UIFont(name: "HoeflerText-Regular", size: 20)
        label.text = "0/200"
        return label
    }()
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    var submitButtonDidTapped: Observable<Void>!
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNaviagationBar()
        setupViews()
        configureUI()
    }
    // MARK: - Helpers
    private func setupNaviagationBar() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.left"),
                                         style: .plain,
                                         target: nil,
                                         action: nil)
        navigationItem.leftBarButtonItem = backButton
        backButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.showAlert(title: "작성을 그만두시겠습니까?",
                               message: "변경 사항은 저장되지 않습니다.",
                               actionTitle: "나가기",
                               actionHandler: {
                    self.navigationController?.popViewController(animated: true)
                })
            }).disposed(by: disposeBag)
        
        
        let submitButton = UIBarButtonItem(title: "완료",
                                           style: .done,
                                           target: .none,
                                           action: .none)
        submitButton.tintColor = UIColor(red: 102/255, green: 103/255, blue: 171/255, alpha: 1)
        submitButtonDidTapped = submitButton.rx.tap.asObservable()
        navigationItem.rightBarButtonItem = submitButton
    }
    
    private func setupViews() {
        answerLabel.isHidden = true
        answerBackground.isHidden = true
        
        [textCountLabel, answerTextView].forEach {
            view.addSubview($0)
        }
    }
    private func configureUI() {
        let textViewWidth = CGSize(width: (self.view.frame.width - 40), height: .infinity)
        
        answerTextView.snp.makeConstraints {
            $0.top.equalTo(koreanQuestionLabel.snp.bottom).offset(40)
            $0.left.right.equalTo(dateLabel)
            $0.height.equalTo(self.answerTextView.sizeThatFits(textViewWidth).height)
        }
        
        textCountLabel.snp.makeConstraints {
            $0.top.equalTo(answerTextView.snp.bottom)
            $0.right.equalTo(dateLabel)
        }
        
        configureTextView()
    }
    
    private func configureTextView() {
        answerTextView.rx.didBeginEditing
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                if self.answerTextView.textColor == .lightGray {
                    self.answerTextView.text = ""
                    self.answerTextView.textColor = .black
                }
            }).disposed(by: disposeBag)
        
        answerTextView.rx.didEndEditing
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                if self.answerTextView.text == "" {
                    self.answerTextView.text = "enter your answer."
                    self.answerTextView.textColor = .lightGray
                }
            }).disposed(by: disposeBag)
        
        answerTextView.rx.text
            .subscribe(onNext: { [weak self] text in
                guard let self else { return }
                guard text != "enter your answer." else {
                    self.textCountLabel.text = "0/200"
                    return
                }
                self.textCountLabel.text = "\(self.answerTextView.text.count)/200"
            }).disposed(by: disposeBag)
        
        answerTextView.rx.didChange
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                let textViewWidth = CGSize(width: (self.view.frame.width - 40), height: .infinity)
                
                self.answerTextView.snp.updateConstraints {
                    $0.height.equalTo(self.answerTextView.sizeThatFits(textViewWidth).height)
                }
            }).disposed(by: disposeBag)
    }
}


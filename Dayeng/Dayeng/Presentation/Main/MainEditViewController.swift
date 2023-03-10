//
//  MainEditViewController.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/03.
//

import UIKit
import RxSwift
import RxCocoa

final class MainEditViewController: UIViewController {
    // MARK: - UI properties
    private lazy var mainView = {
       CommonMainView()
    }()
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
    let viewModel: MainEditViewModel
    var submitButtonDidTapped: Observable<Void>!
    
    // MARK: - Lifecycles
    init(viewModel: MainEditViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideIndicator()
        setupNaviagationBar()
        setupViews()
        bind()
    }
    // MARK: - Helpers
    private func setupNaviagationBar() {
        navigationItem.titleView = UIImageView(image: .dayengLogo)
        navigationController?.navigationBar.tintColor = .black
        
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
                          type: .twoButton,
                          rightActionTitle: "나가기",
                          rightActionHandler: {
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
        mainView.answerLabel.isHidden = true
        mainView.answerBackground.isHidden = true
        
        [mainView, textCountLabel, answerTextView].forEach {
            view.addSubview($0)
        }
        configureUI()
    }
    private func configureUI() {
        let textViewWidth = CGSize(width: (self.view.frame.width - 40), height: .infinity)
        
        mainView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        answerTextView.snp.makeConstraints {
            $0.top.equalTo(mainView.koreanQuestionLabel.snp.bottom).offset(40)
            $0.left.right.equalTo(mainView.dateLabel)
            $0.height.equalTo(self.answerTextView.sizeThatFits(textViewWidth).height)
        }
        
        textCountLabel.snp.makeConstraints {
            $0.top.equalTo(answerTextView.snp.bottom)
            $0.right.equalTo(mainView.dateLabel)
        }
        
        configureTextView()
    }
    
    private func configureTextView() {
        answerTextView.rx.didBeginEditing
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                if self.answerTextView.text == "enter your answer." {
                    self.answerTextView.text = ""
                }
                self.answerTextView.textColor = .black
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
    
    private func bind() {
        let output = viewModel.transform(
            input: .init(
                submitButtonTapped: submitButtonDidTapped,
                answerText: answerTextView.rx.text.orEmpty.asObservable(),
                viewDidLoad: rx.viewDidLoad.map { _ in }.asObservable()
            )
        )
        
        submitButtonDidTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.showIndicator()
            })
            .disposed(by: disposeBag)
        
        output.question
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] question in
                guard let self else { return }
                self.mainView.bindQuestion(question)
            })
            .disposed(by: disposeBag)
        
        output.submitResult
            .subscribe(onNext: { [weak self] error in
                guard let self else { return }
                if let error {
                    self.showAlert(title: "데잉 작성에 실패했습니다.",
                                   message: error.localizedDescription,
                                   type: .oneButton)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
                self.hideIndicator()
            })
            .disposed(by: disposeBag)
    }
}

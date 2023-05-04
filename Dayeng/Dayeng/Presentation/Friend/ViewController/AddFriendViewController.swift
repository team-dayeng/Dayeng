//
//  AddFriendViewController.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/04.
//

import UIKit
import SnapKit
import FirebaseDynamicLinks
import RxSwift
import RxRelay
import RxKeyboard

final class AddFriendViewController: UIViewController {
    // MARK: - UI properties
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        return view
    }()
    private lazy var introductionLabel: UILabel = {
        var label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        label.text = "친구를 맺어,\n일기를 공유해보세요"
        label.numberOfLines = 2
        label.textColor = .black
        return label
    }()
    private lazy var logoImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.image = .dayengLogo
        return imageView
    }()
    private lazy var codeButton: UIButton = {
        var button = UIButton()
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 71/255, green: 71/255, blue: 71/255, alpha: 1),
            .underlineStyle: NSUnderlineStyle.thick.rawValue,
            .font: UIFont.boldSystemFont(ofSize: 20)
        ]
        guard let user = DayengDefaults.shared.user else { return button }
        let attributedString = NSAttributedString(string: "\(user.uid)", attributes: attributes)
        button.setAttributedTitle(attributedString, for: .normal)
        return button
    }()
    private lazy var copyButton: UIButton = {
        var button = UIButton()
        button.setTitle("복사하기", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    private lazy var shareButton: UIButton = {
        var button = UIButton()
        button.setTitle("공유하기", for: .normal)
        button.tintColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.setTitleColor(.black, for: .normal)
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        button.semanticContentAttribute = .forceRightToLeft
        button.layer.cornerRadius = 8
        return button
    }()
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    private lazy var codeTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 20)
        textField.placeholder = "코드 입력"
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 8
        textField.textColor = .dayengGray
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }()
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setTitle("추가하기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.layer.cornerRadius = 8
        return button
    }()
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel: AddFriendViewModel
    
    // MARK: - Lifecycles
    init(viewModel: AddFriendViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setupViews()
        configureUI()
    }
    // MARK: - Helpers
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesEnded(touches, with: event)
      self.view.endEditing(true)
    }
    
    private func bind() {
        let input = AddFriendViewModel.Input(
            addButtonDidTapped:
                addButton.rx.tap.map { _ in
                    self.codeTextField.resignFirstResponder()
                    return self.codeTextField.text ?? "" }.asObservable(),
            shareButtonDidTapped: shareButton.rx.tap.map { _ in }.asObservable()
        )
        let output = viewModel.transform(input: input)
        output.shareButtonResult
            .subscribe(onNext: { url in
                self.showActivityViewController(url: url)
            }, onError: { error in
                self.showAlert(title: "다이나믹 링크 생성 오류", message: "\(error)", type: .oneButton)
            })
            .disposed(by: disposeBag)
        output.addButtonSuccess
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: {
                self.showAlert(title: "친구 등록 성공", type: .oneButton, rightActionHandler: {
                    self.codeTextField.text = ""
                })
            })
            .disposed(by: disposeBag)
        output.addButtonError
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { error in
                self.showAlert(title: "친구 등록 실패", message: error, type: .oneButton, rightActionHandler: {
                    self.codeTextField.text = ""
                })
            })
            .disposed(by: disposeBag)
        RxKeyboard.instance.visibleHeight
            .skip(1)
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                guard let self else { return }
                self.contentView.snp.updateConstraints {
                    $0.bottom.equalToSuperview().inset(keyboardVisibleHeight/2)
                }
                self.view.layoutIfNeeded()
            })
            .disposed(by: disposeBag)
        copyButton.rx.tap
            .bind(onNext: {
                self.showToast(type: .clipboard)
                UIPasteboard.general.string = self.codeButton.currentAttributedTitle?.string
            })
            .disposed(by: disposeBag)
        codeButton.rx.tap
            .bind(onNext: {
                self.showToast(type: .clipboard)
                UIPasteboard.general.string = self.codeButton.currentAttributedTitle?.string
            })
            .disposed(by: disposeBag)
        codeTextField.rx.text
            .orEmpty
            .skip(1)
            .distinctUntilChanged()
            .subscribe(onNext: { changedTest in
                if changedTest == "" {
                    self.codeTextField.textColor = .dayengGray
                } else {
                    self.codeTextField.textColor = .black
                }
            })
            .disposed(by: disposeBag)
    }
    private func setupViews() {
        view.addSubview(contentView)
        contentView.addBackgroundImage()
        [introductionLabel,
         logoImageView,
         codeButton,
         copyButton,
         shareButton,
         separatorView,
         codeTextField,
         addButton].forEach {
            contentView.addSubview($0)
        }
    }
    private func configureUI() {
        title = "친구 추가"
        let heightRatio = view.frame.height / 852
        let widthRatio = view.frame.width / 393
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        introductionLabel.snp.makeConstraints {
            $0.bottom.equalTo(logoImageView.snp.top).offset(-12)
            $0.centerX.equalToSuperview()
        }
        logoImageView.snp.makeConstraints {
            $0.bottom.equalTo(codeButton.snp.top).offset(-5)
            $0.height.equalTo(149*heightRatio)
            $0.width.equalTo(295*heightRatio)
            $0.centerX.equalToSuperview()
        }
        codeButton.snp.makeConstraints {
            $0.bottom.equalTo(copyButton.snp.top)
            $0.height.equalTo(50*heightRatio)
            $0.centerX.equalToSuperview()
        }
        copyButton.snp.makeConstraints {
            $0.bottom.equalTo(shareButton.snp.top).offset(-20*heightRatio)
            $0.centerX.equalToSuperview()
        }
        shareButton.snp.makeConstraints {
            $0.bottom.equalTo(separatorView.snp.top).offset(-40*heightRatio)
            $0.height.equalTo(50*heightRatio)
            $0.width.equalTo(262*widthRatio)
            $0.centerX.equalToSuperview()
        }
        separatorView.snp.makeConstraints {
            $0.bottom.equalTo(codeTextField.snp.top).offset(-40*heightRatio)
            $0.height.equalTo(1)
            $0.width.equalTo(shareButton)
            $0.centerX.equalToSuperview()
        }
        codeTextField.snp.makeConstraints {
            $0.bottom.equalTo(addButton.snp.top).offset(-20*heightRatio)
            $0.height.equalTo(50*heightRatio)
            $0.width.equalTo(shareButton)
            $0.centerX.equalToSuperview()
        }
        addButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-150*heightRatio)
            $0.height.equalTo(50*heightRatio)
            $0.width.equalTo(shareButton)
            $0.centerX.equalToSuperview()
        }
    }
    private func showActivityViewController(url: URL) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        activityVC.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX,
                                                                      y: self.view.bounds.midY,
                                                                      width: 0,
                                                                      height: 0)
        
        present(activityVC, animated: true)
    }
}

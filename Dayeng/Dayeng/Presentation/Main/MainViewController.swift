//
//  MainViewController.swift
//  Dayeng
//
//  Created by 조승기 on 2023/01/31.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class MainViewController: CommonMainViewController {
    // MARK: - UI properties
    private lazy var friendButton = {
        var button: UIButton = UIButton()
        button.tintColor = .black
        let image = UIImage(systemName: "person.2.fill",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 35))
        button.setImage(image, for: .normal)
//        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()
    
    private lazy var settingButton = {
        var button: UIButton = UIButton()
        button.tintColor = .black
        let image = UIImage(systemName: "gear",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 35))
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    // MARK: - Properties
    let viewModel: MainViewModel
    var calendarButtonDidTapped: Observable<Void>!
    var resetButtonDidTapped: Observable<Void>!
    var backgroundDidTapped: Observable<Void>!
    var answerLabelDidTapped: Observable<Void>!
    
    // MARK: - Lifecycles
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNaviagationBar()
        setupViews()
        configureUI()
        bind()
    }
    
    // MARK: - Helpers
    private func setupNaviagationBar() {
        let calendarButton = UIBarButtonItem(image: UIImage(systemName: "calendar"),
                                             style: .plain,
                                             target: nil,
                                             action: nil)
        calendarButtonDidTapped = calendarButton.rx.tap.asObservable()
        
        let resetButton = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"),
                                          style: .plain,
                                          target: nil,
                                          action: nil)
        resetButtonDidTapped = resetButton.rx.tap.asObservable()
        
        navigationItem.leftBarButtonItem = calendarButton
        navigationItem.rightBarButtonItem = resetButton
    }
    
    private func setupViews() {
        [friendButton, settingButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func configureUI() {
        answerBackground.isHidden = answerLabel.text?.count != 0
        
        let answerTapGesture = UITapGestureRecognizer()
        answerLabel.addGestureRecognizer(answerTapGesture)
        answerLabelDidTapped = answerTapGesture.rx.event.map { _ in }.asObservable()
        
        let backgroundTapGesture = UITapGestureRecognizer()
        answerBackground.addGestureRecognizer(backgroundTapGesture)
        backgroundDidTapped = backgroundTapGesture.rx.event.map { _ in }.asObservable()
        
        friendButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.right.equalToSuperview().offset(-55)
            $0.height.width.equalTo(50)
        }
        
        settingButton.snp.makeConstraints {
            $0.bottom.equalTo(friendButton.snp.bottom)
            $0.right.equalToSuperview().offset(-10)
            $0.height.width.equalTo(50)
        }
    }
    
    func bind() {
        backgroundDidTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                let editViewController = MainEditViewController()
                self.navigationController?.pushViewController(editViewController, animated: true)
            })
    }
}

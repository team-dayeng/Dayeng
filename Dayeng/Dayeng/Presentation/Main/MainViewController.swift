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

final class MainViewController: UIViewController {
    // MARK: - UI properties
    private var collectionView: UICollectionView!
    
    private lazy var friendButton = {
        var button: UIButton = UIButton()
        button.tintColor = .black
        let image = UIImage(systemName: "person.2.fill",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 35))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private lazy var settingButton = {
        var button: UIButton = UIButton()
        button.tintColor = .black
        let image = UIImage(systemName: "gear",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 35))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private lazy var calendarButton = UIBarButtonItem(
        image: UIImage(systemName: "calendar"),
        style: .plain,
        target: nil,
        action: nil)
    
    private lazy var resetButton = UIBarButtonItem(
        image: UIImage(systemName: "arrow.clockwise"),
        style: .plain,
        target: nil,
        action: nil)
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    let viewModel: MainViewModel
    
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
        configureCollectionView()
        setupViews()
        bind()
    }
    
    // MARK: - Helpers
    private func setupNaviagationBar() {
        navigationItem.titleView = UIImageView(image: .dayengLogo)
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.title = ""
        navigationItem.leftBarButtonItem = calendarButton
        navigationItem.rightBarButtonItem = resetButton
    }
    
    private func setupViews() {
        view.addBackgroundImage()
        [collectionView, friendButton, settingButton].forEach {
            view.addSubview($0)
        }
        configureUI()
    }
    
    private func configureUI() {
        collectionView.snp.makeConstraints {
            $0.top.left.right.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }
        
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
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(MainCell.self, forCellWithReuseIdentifier: MainCell.identifier)
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.backgroundColor = .clear
    }
    
    private func collectionViewLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .paging
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func bind() {
        let input = MainViewModel.Input(
            viewWillAppear: rx.methodInvoked(#selector(viewWillAppear(_ :))).map { _ in
                self.showIndicator()
            }.asObservable(),
            resetButtonDidTapped: resetButton.rx.tap.asObservable(),
            friendButtonDidTapped: friendButton.rx.tap.asObservable(),
            settingButtonDidTapped: settingButton.rx.tap.asObservable(),
            calendarButtonDidTapped: calendarButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        output.successLoad
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.hideIndicator()
                self.collectionView.dataSource = self
                self.collectionView.delegate = self
                
                if let user = DayengDefaults.shared.user {
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.collectionView.scrollToItem(
                            at: IndexPath(row: user.currentIndex, section: 0),
                            at: .centeredHorizontally,
                            animated: false)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if let user = DayengDefaults.shared.user {
            return user.currentIndex + 1
        }
        return 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MainCell.identifier,
            for: indexPath
        ) as? MainCell else {
            return UICollectionViewCell()
        }
        
        if DayengDefaults.shared.questions.count > indexPath.row {
            cell.bindQuestion(DayengDefaults.shared.questions[indexPath.row])
        }
        if let user = DayengDefaults.shared.user,
           user.answers.count > indexPath.row {
            cell.bindAnswer(user.answers[indexPath.row])
        }
        
        return cell
    }
}

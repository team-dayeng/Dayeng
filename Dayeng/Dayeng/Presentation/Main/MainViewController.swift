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
        collectionView.delegate = self
        collectionView.register(MainCell.self, forCellWithReuseIdentifier: MainCell.identifier)
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.backgroundColor = .clear
        
        if let user = DayengDefaults.shared.user {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.collectionView.scrollToItem(
                    at: IndexPath(row: user.currentIndex, section: 0),
                    at: .centeredHorizontally,
                    animated: false)
            }
        }
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
            resetButtonDidTapped: resetButton.rx.tap.asObservable(),
            friendButtonDidTapped: friendButton.rx.tap.asObservable(),
            settingButtonDidTapped: settingButton.rx.tap.asObservable(),
            calendarButtonDidTapped: calendarButton.rx.tap.asObservable(),
        )
        _ = viewModel.transform(input: input)
        output.questionsAnswers
            .bind(to: collectionView.rx.items(cellIdentifier: MainCell.identifier, cellType: MainCell.self)
            ) { [weak self] (index, questionAnswer, cell) in
                let (question, answer) = questionAnswer
                guard let self else { return }
                
                cell.mainView.bindQuestion(question)
                let disposable = cell.mainView.editButtonDidTapped
                    .map { index }
                    .debug("왜안돼?")
                    .bind(to: self.editButtonDidTapped)
                
                self.editButtonDisposables[index] = disposable
                
                if let answer {
                    cell.mainView.bindAnswer(answer)
                }
            }
            .disposed(by: disposeBag)
        
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        editButtonDisposables[indexPath.row]?.dispose()
        editButtonDisposables.removeValue(forKey: indexPath.row)
    }
}

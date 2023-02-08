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
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
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
        configureCollectionView()
        bind()
    }
    
    // MARK: - Helpers
    private func setupNaviagationBar() {
        navigationItem.titleView = UIImageView(image: .dayengLogo)
        navigationController?.navigationBar.tintColor = .black
        
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
        addBackgroundImage()
        [friendButton, settingButton].forEach {
            view.addSubview($0)
        }
        configureUI()
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MainCell.self, forCellWithReuseIdentifier: MainCell.identifier)
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
    }
    
    private func collectionViewLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .paging
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func configureUI() {
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

    }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCell.identifier,
                                                            for: indexPath) as? MainCell else {
            return UICollectionViewCell()
        }
        return cell
    }
}

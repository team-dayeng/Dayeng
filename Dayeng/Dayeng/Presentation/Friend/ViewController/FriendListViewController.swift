//
//  FriendListViewController.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/03.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class FriendListViewController: UIViewController {
    
    // MARK: - UI properties
    private let plusButton = UIBarButtonItem(
        image: UIImage(systemName: "plus"),
        style: .plain,
        target: nil,
        action: nil
    )
    
    private var collectionView: UICollectionView!
    private let emptyLabel: UILabel = {
        var label = UILabel()
        label.text = "아직 친구가 없어요.\n\n우측 상단 플러스 버튼을 눌러\n친구를 추가해보세요!"
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    // MARK: - Properties
    private let viewModel: FriendListViewModel
    private var disposeBag = DisposeBag()
    
    typealias DataSource = UICollectionViewDiffableDataSource<String, User>
    private var dataSource: DataSource?
    
    // MARK: - Lifecycles
    init(viewModel: FriendListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupCollectionView()
        setupViews()
        configureUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
}

extension FriendListViewController {
    
    // MARK: - Helpers
    
    private func setupNavigationBar() {
        title = "친구 목록"
        navigationItem.rightBarButtonItem = plusButton
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: setupCollectionViewLayout()
        )
        collectionView.backgroundColor = UIColor.clear.withAlphaComponent(0)
        
        collectionView.register(
            FriendListCell.self,
            forCellWithReuseIdentifier: FriendListCell.identifier
        )
        configureDataSource()
    }
    
    private func setupCollectionViewLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { (_, _) -> NSCollectionLayoutSection in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(70)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let itemInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0)
            item.contentInsets = itemInsets
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [item]
            )
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
    }
    
    private func configureDataSource() {
        dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: FriendListCell.identifier,
                    for: indexPath) as? FriendListCell else {
                    return FriendListCell()
                }
                cell.bind(userInfo: item)
                return cell
        })
    }
    
    private func setupViews() {
        view.addBackgroundImage()
        view.addSubview(collectionView)
        view.addSubview(emptyLabel)
    }
    
    private func configureUI() {
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(5)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        emptyLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private func bind() {
        let input = FriendListViewModel.Input(
            viewWillAppear: rx.methodInvoked(#selector(viewWillAppear(_ :))).map { _ in
                self.showIndicator()
            }.asObservable(),
            plusButtonDidTapped: plusButton.rx.tap.asObservable(),
            friendIndexDidTapped: collectionView.rx.itemSelected.asObservable().map { indexPath in
                if let cell = self.collectionView.cellForItem(at: indexPath) as? FriendListCell,
                   let user = cell.userInfo {
                   return user
                }
                return nil
            }
        )
        let output = viewModel.transform(input: input)
        
        output.friends
            .subscribe(onNext: { [weak self] friends in
                guard let self else { return }
                self.emptyLabel.isHidden = !friends.isEmpty
                self.makeSnapshot(friends: friends)
            })
            .disposed(by: disposeBag)
    }
    
    private func makeSnapshot(friends: [User]) {
        guard let dataSource else { return }
        var snapshot = dataSource.snapshot()
        if !snapshot.sectionIdentifiers.contains("friends") {
            snapshot.appendSections(["friends"])
        }
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: "friends"))
        snapshot.appendItems(friends, toSection: "friends")
        dataSource.apply(snapshot) {
            self.hideIndicator()
        }
    }
}

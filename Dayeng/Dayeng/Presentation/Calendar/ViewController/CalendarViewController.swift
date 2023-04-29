//
//  CommonCalendarViewController.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/01.
//

import UIKit
import SnapKit
import RxSwift

final class CalendarViewController: UIViewController {
    // MARK: - UI properties
    private var collectionView: UICollectionView!
    
    private lazy var homeButton = UIBarButtonItem(image: UIImage(systemName: "house"),
                                                  style: .plain,
                                                  target: nil,
                                                  action: nil)
    
    // MARK: - Properties
    private let viewModel: CalendarViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycles
    init(viewModel: CalendarViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        configureUI()
        bind()
    }
    
    // MARK: - Helpers
    private func bind() {
        let input = CalendarViewModel.Input(
            viewDidLoad: rx.viewDidLoad.map { _ in }.asObservable(),
            homeButtonDidTapped: homeButton.rx.tap.asObservable(),
            cellDidTapped: collectionView.rx.itemSelected.map { $0.row }
        )
        
        let output = viewModel.transform(input: input)
        
        configureNavigationBar(ownerType: output.ownerType)
        
        output.answers
            .bind(to: collectionView.rx.items(
                cellIdentifier: CommonCalendarCell.identifier,
                cellType: CommonCalendarCell.self
            )) { (index, answer, cell) in
                cell.bind(index: index, answer: answer, currentIndex: output.currentIndex)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupViews() {
        view.addBackgroundImage()
    }
    
    private func configureUI() {
        configureCollectionView()
    }
    
    private func configureNavigationBar(ownerType: OwnerType) {
        var title = ""
        
        switch ownerType {
        case .mine:
            title = "달력"
        case .friend(let user):
            title = "\(user.name)님의 달력"
            navigationItem.rightBarButtonItem = homeButton
        }
        
        navigationItem.title = title
        navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 20,
                                                                                            weight: .bold),
                                                                   .foregroundColor: UIColor.black]
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.topItem?.title = ""
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        
        collectionView.register(CommonCalendarCell.self, forCellWithReuseIdentifier: CommonCalendarCell.identifier)
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(30)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(view.frame.height/3)
        }
    }
    
    private func collectionViewLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2)
        
        let rowGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .fractionalHeight(1))
        let rowGroup = NSCollectionLayoutGroup.horizontal(layoutSize: rowGroupSize,
                                                          subitem: item,
                                                          count: 5)
        rowGroup.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15)
        
        let columnGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                     heightDimension: .fractionalHeight(1.0))
        let columnGroup = NSCollectionLayoutGroup.vertical(layoutSize: columnGroupSize,
                                                           subitem: rowGroup,
                                                           count: 4)

        let section = NSCollectionLayoutSection(group: columnGroup)
        section.orthogonalScrollingBehavior = .paging
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

//
//  CommonCalendarViewController.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/01.
//

import UIKit
import SnapKit

final class CommonCalendarViewController: UIViewController {
    // MARK: - UI properties
    private var collectionView: UICollectionView!
    
    // MARK: - Properties
    private let ownerType: OwnerType
    
    // MARK: - Lifecycles
    init(ownerType: OwnerType) {
        self.ownerType = ownerType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupViews()
        configureUI()
    }
    
    // MARK: - Helpers
    private func setupViews() {
        
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        addBackgroundImage()
        configureNavigationBar()
        configureCollectionView()
    }
    
    private func configureNavigationBar() {
        var title = "달력"
        
        if ownerType == .friend {
            title = "userName님의 달력"
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "house"),
                                                                       style: .plain,
                                                                       target: self,
                                                                       action: #selector(rightBarButtonDidTapped))
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
        collectionView.delegate = self
        collectionView.dataSource = self
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
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15)
        
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
    
    @objc private func rightBarButtonDidTapped() {
        // 자신의 화면으로 돌아가기
    }
}

extension CommonCalendarViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // 365 대신 싱글톤에 저장되어있는 질문 개수
        return 365
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommonCalendarCell.identifier,
                                                            for: indexPath) as? CommonCalendarCell else {
            return UICollectionViewCell()
        }
        cell.configureNumberLabel(number: indexPath.row + 1)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //싱글톤에서 알맞은 질문과 대답을 찾은 후, 뷰전환
        print(indexPath.row + 1)
    }
}

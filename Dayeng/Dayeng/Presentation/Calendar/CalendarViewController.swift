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
    private let ownerType: OwnerType
    private let viewModel: CalendarViewModel
    
    private let disposeBag = DisposeBag()
    private let cannotFindUserError = PublishSubject<Void>()
    
    // MARK: - Lifecycles
    init(ownerType: OwnerType, viewModel: CalendarViewModel) {
        self.ownerType = ownerType
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
            homeButtonDidTapped: homeButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        output.answers
            .subscribe(onNext: {

            })
            .disposed(by: disposeBag)
    }
    
    private func setupViews() {
        view.addBackgroundImage()
    }
    
    private func configureUI() {
        configureNavigationBar()
        configureCollectionView()
    }
    
    private func configureNavigationBar() {
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

extension CalendarViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DayengDefaults.shared.questions.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CommonCalendarCell.identifier,
            for: indexPath
        ) as? CommonCalendarCell else {
            return UICollectionViewCell()
        }
        
        let index = indexPath.row
        
        switch ownerType {
        case .mine:
            guard let user = DayengDefaults.shared.user else {
                self.showCannotFindUserAlert()
                return cell
            }
            cell.bind(index: index, answer: (user.answers.count > index ? user.answers[index] : nil))
        case .friend(let user):
            cell.bind(index: index, answer: (user.answers.count > index ? user.answers[index] : nil))
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 싱글톤에서 알맞은 질문과 대답을 찾은 후, 뷰전환
        print(indexPath.row + 1)
    }
    
    private func showCannotFindUserAlert() {
        showAlert(
            title: AlertMessageType.cannotFindUser.title,
            message: AlertMessageType.cannotFindUser.message,
            type: .oneButton,
            rightActionHandler: { [weak self] in
                guard let self else { return }
                self.cannotFindUserError.onNext(())
        })
    }
}

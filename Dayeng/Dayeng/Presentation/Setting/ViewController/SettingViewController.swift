//
//  SettingViewController.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/06.
//

import UIKit
import RxSwift
import SnapKit
import RxCocoa
import MessageUI

final class SettingViewController: UIViewController {
    enum Sections: Int {
        case alarm
        case account
        case etc
        
        var title: String {
            switch self {
            case .alarm:
                return "알람"
            case .account:
                return "계정"
            case .etc:
                return "기타"
            }
        }
    }
    
    enum Items: Int {
        case alarm
        case logout
        case withDrwal
        case recommend
        case openSource
        case aboutMe
        case inquiry
        
        var title: String {
            switch self {
            case .alarm:
                return "알람 설정"
            case .logout:
                return "로그아웃"
            case .withDrwal:
                return "회원탈퇴"
            case .recommend:
                return "질문 추천하기"
            case .openSource:
                return "오픈소스 목록보기"
            case .aboutMe:
                return "정보"
            case .inquiry:
                return "문의하기"
            }
        }
    }
    
    // MARK: - UI properties
    private var collectionView: UICollectionView!
    
    // MARK: - Properties
    typealias DataSource = UICollectionViewDiffableDataSource<Sections, Items>
    private var viewModel: SettingViewModel
    private var dataSource: DataSource?
    private var disposeBag = DisposeBag()
    
    private var logoutDidTapped = PublishSubject<Void>()
    private var withdrawalDidTapped = PublishSubject<Void>()
    
    // MARK: - Lifecycles
    init(viewModel: SettingViewModel) {
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
        makeSnapshot()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavigationBar()
    }
    
    // MARK: - Helpers
    private func bind() {
        let input = SettingViewModel.Input(
            cellDidTapped: collectionView.rx.itemSelected.asObservable(),
            logoutDidTapped: logoutDidTapped.asObservable(),
            withdrawalDidTapped: withdrawalDidTapped.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        collectionView.rx.itemSelected
            .filter { $0 == IndexPath(row: 0, section: 1) }     // 로그아웃
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                self.showAlert(
                    title: "로그아웃 하시겠습니까?",
                    type: .twoButton,
                    rightActionHandler: { [weak self] in
                        guard let self else { return }
                        self.logoutDidTapped.onNext(())
                })
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .filter { $0 == IndexPath(row: 1, section: 1) }     // 회원 탈퇴
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                self.showAlert(
                    title: "정말 탈퇴하시겠습니까?",
                    type: .twoButton,
                    rightActionHandler: { [weak self] in
                        guard let self else { return }
                        self.withdrawalDidTapped.onNext(())
                })
            })
            .disposed(by: disposeBag)
        
        output.showMailComposeViewController
            .asDriver(onErrorJustReturn: .inquiry)
            .drive(onNext: { [weak self] type in
                guard let self else { return }
                if !MFMailComposeViewController.canSendMail() {
                    self.showAlert(title: "에러가 발생했어요.", message: "다시 전송해주세요!", type: .oneButton)
                    return
                }
                
                let viewController = MFMailComposeViewController()
                viewController.mailComposeDelegate = self
                viewController.setToRecipients([type.recipient])
                viewController.setSubject(type.subject)
                viewController.setMessageBody(type.messageBody, isHTML: false)
                
                self.navigationController?.present(viewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        output.logoutFailed
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.showAlert(
                    title: "로그아웃에 실패했습니다",
                    message: "다시 시도해주세요",
                    type: .oneButton
                )
            })
            .disposed(by: disposeBag)
        
        output.withdrawalFailed
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.showAlert(
                    title: "회원 탈퇴에 실패했습니다",
                    message: "다시 시도해주세요",
                    type: .oneButton
                )
            })
            .disposed(by: disposeBag)
    }
    
    private func setupViews() {
        view.addBackgroundImage()
    }
    
    private func configureUI() {
        configureCollectionView()
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "설정"
        navigationController?.navigationBar.tintColor = .black
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.alwaysBounceHorizontal = false
        collectionView.alwaysBounceVertical = false
        collectionView.backgroundColor = .clear
        
        collectionView.register(SettingCell.self, forCellWithReuseIdentifier: SettingCell.identifier)
        collectionView.register(SettingHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SettingHeaderView.identifier)
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.bottom.equalToSuperview()
        }
        
        configureDataSource()
    }
    
    private func collectionViewLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .absolute(40))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(40))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [header]
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView,
                                cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SettingCell.identifier,
                for: indexPath) as? SettingCell else {
                return UICollectionViewCell()
            }
            cell.bind(text: item.title)
            
            return cell
        })
        
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader,
                  let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: SettingHeaderView.identifier,
                    for: indexPath) as? SettingHeaderView
            else { return UICollectionReusableView() }
            
            guard let sectionType = Sections(rawValue: indexPath.section) else { return header }
            header.bind(text: sectionType.title)
            
            return header
        }
    }
    
    private func makeSnapshot() {
        guard let dataSource else { return }
        var snapshot = dataSource.snapshot()
        snapshot.appendSections([.alarm, .account, .etc])
        snapshot.appendItems([.alarm], toSection: .alarm)
        snapshot.appendItems([.logout, .withDrwal], toSection: .account)
        snapshot.appendItems([.recommend, .inquiry, .openSource, .aboutMe], toSection: .etc)
        
        dataSource.apply(snapshot)
    }
}

extension SettingViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        if error != nil {
            self.showAlert(title: "에러가 발생했어요.", message: "다시 전송해주세요!", type: .oneButton)
        }
        controller.dismiss(animated: true)
    }
}

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
import RxGesture
import GoogleMobileAds

final class MainViewController: UIViewController, GADBannerViewDelegate, GADFullScreenContentDelegate {
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
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    private let viewModel: MainViewModel
    private let editButtonDidTapped = PublishRelay<Int>()
    private let titleViewDidTapped = PublishRelay<Void>()
    private var editButtonDisposables = [Int: Disposable]()
    private let adsViewDidTapped = PublishRelay<Void>()
    private let adsDidWatched = PublishRelay<Void>()
    private var initialIndexPath: IndexPath?
    private var rewardedAd: GADRewardedAd?
    
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
        setupAds()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showIndicator()
    }
    
    // MARK: - Helpers
    private func setupNaviagationBar() {
        let titleImageView = UIImageView(image: .dayengLogo)
        let tapGestureRecognizer = UITapGestureRecognizer()
        titleImageView.isUserInteractionEnabled = true
        titleImageView.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.rx.event.map { _ in }
            .bind(to: titleViewDidTapped)
            .disposed(by: disposeBag)
        
        navigationItem.titleView = titleImageView
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.title = ""
        navigationController?.navigationBar.topItem?.title = ""
    }
    
    private func setupViews() {
        view.addBackgroundImage()
        [collectionView, friendButton, settingButton].forEach {
            view.addSubview($0)
        }
        configureUI()
    }
    
    private func setupAds() {
        GADRewardedAd.load(withAdUnitID: "ca-app-pub-3402143822000520/5224075704",
                           request: GADRequest()) { (ads, error) in
          if let error = error {
            print("Rewarded ad failed to load with error: \(error.localizedDescription)")
            return
          }
          print("Loading Succeeded")
          self.rewardedAd = ads
          self.rewardedAd?.fullScreenContentDelegate = self
        }
    }
    
    private func configureUI() {
        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
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
        collectionView.isScrollEnabled = false
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
            viewWillAppear: rx.viewWillAppear.map { _ in }.asObservable(),
            friendButtonDidTapped: friendButton.rx.tap.asObservable(),
            settingButtonDidTapped: settingButton.rx.tap.asObservable(),
            calendarButtonDidTapped: calendarButton.rx.tap.asObservable(),
            editButtonDidTapped: editButtonDidTapped.asObservable(),
            adsViewDidTapped: adsViewDidTapped.asObservable(),
            adsDidWatched: adsDidWatched.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.questionsAnswers
            .do(onNext: { [weak self] _ in
                guard let self else { return }
                self.hideIndicator()
            })
            .bind(to: collectionView.rx.items(cellIdentifier: MainCell.identifier, cellType: MainCell.self)
            ) { (_, questionAnswer, cell) in
                let (question, answer) = questionAnswer
                cell.mainView.bind(question, answer)
                cell.adsContentView.rx.tapGesture()
                    .when(.recognized)
                    .subscribe(onNext: { [weak self] _ in
                        guard let self else { return }
                        self.adsViewDidTapped.accept(())
                    })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        output.firstShowingIndex
            .subscribe(onNext: { [weak self] index in
                guard let self, let index = index else { return }
                self.initialIndexPath = IndexPath(row: index, section: 0)
            })
            .disposed(by: disposeBag)
        
        titleViewDidTapped.withLatestFrom(output.startBluringIndex)
            .subscribe(onNext: { [weak self] startBluringIndex in
                guard let self else { return }
                let indexPath = IndexPath(
                    row: (startBluringIndex ?? output.questionsAnswers.value.count)-1,
                    section: 0
                )
                
                self.collectionView.scrollToItem(at: indexPath,
                                                 at: .centeredVertically,
                                                 animated: true)
            })
            .disposed(by: disposeBag)

        output.startBluringIndex
            .subscribe(onNext: { [weak self] startBluringIndex in
                guard let self else { return }
                if let showingIndex = output.firstShowingIndex.value {
                    self.initialIndexPath = IndexPath(row: showingIndex, section: 0)
                    return
                }
                self.initialIndexPath = IndexPath(
                    row: (startBluringIndex ?? output.questionsAnswers.value.count)-1,
                    section: 0)
            })
            .disposed(by: disposeBag)
    
        if output.ownerType != .mine {
            bindFriend(output: output)
            return
        }
        
        output.adsViewTapResult
            .subscribe(onNext: { [weak self] result in
                guard let self else { return }
                if result {
                    if let rewardedAd = self.rewardedAd {
                        rewardedAd.present(fromRootViewController: self, userDidEarnRewardHandler: {
                            self.adsDidWatched.accept(())
                            self.setupAds()
                        })
                    }
                } else {
                    self.showAlert(title: "답변하지 않은 질문이 있습니다.", type: .oneButton)
                }
            })
            .disposed(by: disposeBag)
        
        navigationItem.leftBarButtonItem = calendarButton
        
        bindCollectionViewWillDisplayCell(startingBlurIndex: output.startBluringIndex)
        bindCollectionViewDidEndDisplayingCell()
    }
    
    private func bindFriend(output: MainViewModel.Output) {
        friendButton.isHidden = true
        settingButton.isHidden = true
        collectionView.rx.willDisplayCell
            .subscribe(onNext: { [weak self] _, _ in
                guard let self else { return }
                if let initialIndexPath = self.initialIndexPath {
                    self.collectionView.scrollToItem(at: initialIndexPath,
                                                     at: .centeredVertically,
                                                     animated: false)
                    self.initialIndexPath = nil
                }
            })
            .disposed(by: disposeBag)
    }

    private func bindCollectionViewWillDisplayCell(startingBlurIndex: BehaviorRelay<Int?>) {
        collectionView.rx.willDisplayCell
            .subscribe(onNext: { [weak self] cell, indexPath in
                guard let self,
                      let cell = cell as? MainCell else { return }

                if let initialIndexPath = self.initialIndexPath {
                    self.collectionView.scrollToItem(at: initialIndexPath,
                                                     at: .centeredVertically,
                                                     animated: false)
                    self.initialIndexPath = nil
                }

                self.editButtonDisposables[indexPath.row] = cell.mainView.editButtonDidTapped
                    .map { indexPath.row }
                    .bind(to: self.editButtonDidTapped)
                guard let blurIndex = startingBlurIndex.value else { return }
                if indexPath.row >= blurIndex {
                    cell.blur()
                }
                
                if indexPath.row == blurIndex {
                    cell.setupAds()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func bindCollectionViewDidEndDisplayingCell() {
        collectionView.rx.didEndDisplayingCell
            .subscribe(onNext: { [weak self] _, indexPath in
                guard let self else { return }
                self.editButtonDisposables[indexPath.row]?.dispose()
                self.editButtonDisposables.removeValue(forKey: indexPath.row)
            })
            .disposed(by: disposeBag)
    }
}

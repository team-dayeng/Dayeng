//
//  AlarmDaySettingViewController.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/06.
//

import UIKit
import RxSwift
import SnapKit
import RxRelay

final class AlarmDaySettingViewController: UIViewController {
    enum DayType: Int {
        case mon
        case tue
        case wed
        case thu
        case fri
        case sat
        case sun
        
        var string: String {
            switch self {
            case .mon:
                return "월요일마다"
            case .tue:
                return "화요일마다"
            case .wed:
                return "수요일마다"
            case .thu:
                return "목요일마다"
            case .fri:
                return "금요일마다"
            case .sat:
                return "토요일마다"
            case .sun:
                return "일요일마다"
            }
        }
    }
    
    // MARK: - UI properties
    private var collectionView: UICollectionView!
    // MARK: - Properties
    var disposeBag = DisposeBag()
    let isSelectedCells: BehaviorRelay<[Bool]>
    
    // MARK: - Lifecycles
    init(isSelectedCells: BehaviorRelay<[Bool]>) {
        self.isSelectedCells = isSelectedCells
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBackgroundImage()
        configureCollectionView()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavigationBar()
    }
    
    // MARK: - Helpers
    private func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = .gray
        collectionView.layer.cornerRadius = 10
        collectionView.layer.borderWidth = 1
        collectionView.layer.borderColor = UIColor.gray.cgColor
        
        collectionView.alwaysBounceVertical = false
        
        collectionView.register(AlarmDayCell.self, forCellWithReuseIdentifier: AlarmDayCell.identifier)
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalToSuperview().inset(view.frame.height/2.2)
        }
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "요일 설정"
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.topItem?.title = ""
    }
    
    private func bind() {
        isSelectedCells
            .subscribe(onNext: { [weak self] isSelectedCells in
                guard let self else { return }
                isSelectedCells
                    .enumerated()
                    .forEach { index, isSelected in
                        let cell = self.collectionView.cellForItem(at: IndexPath(row: index, section: 0))
                        guard let cell = cell as? AlarmDayCell else { return }
                        cell.tappedCell(isSelected: isSelected)
                    }
                
            }).disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self else { return }
                var isSelectedCellsValue = self.isSelectedCells.value
                isSelectedCellsValue[indexPath.row].toggle()
                self.isSelectedCells.accept(isSelectedCellsValue)
            }).disposed(by: disposeBag)
    }
}

extension AlarmDaySettingViewController: UICollectionViewDelegate, UICollectionViewDataSource,
                                         UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height = (collectionView.frame.height - 6) / 7
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlarmDayCell.identifier,
                                                            for: indexPath) as? AlarmDayCell else {
            return UICollectionViewCell()
        }
        guard let dayType = DayType(rawValue: indexPath.row) else { return UICollectionViewCell() }
        
        cell.bind(text: dayType.string)
        cell.tappedCell(isSelected: isSelectedCells.value[indexPath.row])
        return cell
    }
}

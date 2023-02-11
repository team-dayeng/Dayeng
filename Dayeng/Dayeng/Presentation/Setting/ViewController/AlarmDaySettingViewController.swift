//
//  AlarmDaySettingViewController.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/06.
//

import UIKit
import RxSwift
import SnapKit

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
    private lazy var backgroundImage: UIImageView = {
        var imageView: UIImageView = UIImageView()
        imageView.image = UIImage(named: "paperBackground")
        
        return imageView
    }()
    
    private var collectionView: UICollectionView!
    // MARK: - Properties
    var isSelectedCells: [IndexPath: Bool]
    
    // MARK: - Lifecycles
    init() {
        isSelectedCells = [:]
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        configureUI()
        configureCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavigationBar()
    }
    
    // MARK: - Helpers

    private func setupViews() {
        view.addSubview(backgroundImage)
    }
    
    private func configureUI() {
        backgroundImage.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(-50)
            $0.top.bottom.equalToSuperview().inset(-100)
        }
    }
    
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
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell  = collectionView.cellForItem(at: indexPath) as? AlarmDayCell else { return }
        
        isSelectedCells[indexPath] = !cell.isSelect
        cell.tappedCell(isSelected: !cell.isSelect)
    }
}

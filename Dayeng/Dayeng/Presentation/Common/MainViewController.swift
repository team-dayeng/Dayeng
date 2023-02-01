//
//  File.swift
//  Dayeng
//
//  Created by 조승기 on 2023/01/30.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift

final class MainViewController: UIViewController {
    // MARK: - UI properties
    private lazy var dateLabel = {
        var label: UILabel = UILabel()
        label.font = UIFont(name: "HoeflerText-Regular", size: 14)
        label.text = Date().convertToString(format: "yyyy.MM.dd.E")
        return label
    }()
    
    private lazy var questionLabel = {
        var label: UILabel = UILabel()
        label.font = UIFont(name: "HoeflerText-Regular", size: 20)
        label.text = "Q1. where do you want to live?"
        return label
    }()
    
    // MARK: - Properties
    var calendarButtonTap: Observable<Void>!
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        view.backgroundColor = .lightGray
    }
    // MARK: - Helpers
    private func configureUI() {
        title = "Dayeng"
        let calendar =  UIBarButtonItem(
            image: UIImage(systemName: "calendar"),
            style: .plain,
            target: self,
            action: nil
        )
        calendarButtonTap = calendar.rx.tap.asObservable()
        navigationItem.leftBarButtonItem = calendar
        navigationController?.navigationBar.tintColor = .black
        
        [dateLabel, questionLabel].forEach { view.addSubview($0) }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100)
            $0.left.equalToSuperview().offset(20)
        }
        
        questionLabel.snp.makeConstraints {
            $0.left.equalTo(dateLabel)
            $0.top.equalTo(dateLabel.snp.bottom).offset(10)
        }
    }
}

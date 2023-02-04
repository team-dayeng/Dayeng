//
//  MainPageViewController.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/04.
//

import Foundation
    var calendarButtonDidTapped: Observable<Void>!
    var resetButtonDidTapped: Observable<Void>!
    
        setupNaviagationBar()
    private func setupNaviagationBar() {
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

//
//  MainPageViewController.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/04.
//

import UIKit
import SnapKit
import RxSwift

class MainPageViewController: ViewController {
    // MARK: - UI properties
    private lazy var pageViewController: UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                      navigationOrientation: .horizontal)
        return pageViewController
    }()
    private lazy var leftViewController: CommonMainViewController = {
        let viewController = MainViewController(viewModel: MainViewModel())
        viewController.backgroundImage.alpha = 0.5
        return viewController
    }()
    
    private lazy var centerViewController: CommonMainViewController = {
        MainViewController(viewModel: MainViewModel())
    }()
    
    private lazy var rightViewController: CommonMainViewController = {
        MainViewController(viewModel: MainViewModel())
    }()
    
    private lazy var arrayViewControllers: [CommonMainViewController] = {
        [leftViewController, centerViewController, rightViewController]
    }()
    
    // MARK: - Properties
    var calendarButtonDidTapped: Observable<Void>!
    var resetButtonDidTapped: Observable<Void>!
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNaviagationBar()
        setupViews()
        configureUI()
    }
    
    // MARK: - Helpers
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

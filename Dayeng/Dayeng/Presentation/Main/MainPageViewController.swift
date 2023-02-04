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
    
    private func setupViews() {
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.setViewControllers([centerViewController],
                                              direction: .forward,
                                              animated: true)
    }
    
    private func configureUI() {
        pageViewController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension MainPageViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let viewControllerBefore = viewController as? CommonMainViewController,
              let index = arrayViewControllers.firstIndex(of: viewControllerBefore) else {
            return nil
        }
        return arrayViewControllers[(index - 1) < 0 ? 2 : index - 1]
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let viewControllerAfter = viewController as? CommonMainViewController,
              let index = arrayViewControllers.firstIndex(of: viewControllerAfter) else {
            return nil
        }
        return arrayViewControllers[(index + 1) % 3]
    }
}

extension MainPageViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        
    }
}

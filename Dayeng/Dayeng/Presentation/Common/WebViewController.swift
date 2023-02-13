//
//  WebViewController.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/12.
//

import UIKit
import WebKit

final class WebViewController: UIViewController {
    // MARK: - UI properties
    private var webView: WKWebView!
    
    // MARK: - Properties
    private let url: String
    
    // MARK: - Lifecycles
    init(url: String) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebView()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadWebView()
    }
    
    // MARK: - Helpers
    
    private func setupWebView() {
        webView = WKWebView(frame: view.frame)
        view.addSubview(webView)
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
    }
    
    private func configureUI() {
        view.backgroundColor = .white
       
        webView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func loadWebView() {
        guard let url = URL(string: self.url) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

extension WebViewController: WKUIDelegate, WKNavigationDelegate{
    
}

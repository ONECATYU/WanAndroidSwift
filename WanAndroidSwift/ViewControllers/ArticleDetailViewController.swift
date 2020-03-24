//
//  ArticleDetailViewController.swift
//  WanAndroidSwift
//
//  Created by 余汪送 on 2020/3/17.
//  Copyright © 2020 余汪送. All rights reserved.
//

import UIKit
import WebKit

class ArticleDetailViewController: BaseViewController {
    
    let id: String
    let url: String
    let name: String?
    
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        return webView
    }()
    
    init(id: String, url: String, name: String?) {
        self.id = id
        self.url = url
        self.name = name
        super.init(nibName: nil, bundle: nil)
        self.title = name ?? "文章详情"
        self.hidesBottomBarWhenPushed = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configViews()
        webViewLoadUrl(urlString: url)
    }
    
    func webViewLoadUrl(urlString: String) {
        guard let url = URL(string: urlString) else {
            showError(msg: "加载文章详情失败!")
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func configViews() {
        view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        webView.navigationDelegate = self
    
        appTheme.rx.bind({ $0.backgroundColor }, to: webView.rx.backgroundColor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ArticleDetailViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showHUD()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideHUD()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showError(msg: error.localizedDescription)
    }
    
}

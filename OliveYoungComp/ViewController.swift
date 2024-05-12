//
//  ViewController.swift
//  OliveYoungComp
//
//  Created by 김태현 on 5/12/24.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false // 오토레이아웃 제약을 직접 설정
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            webView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor)
        ])

        if let url = URL(string: "https://www.oliveyoung.co.kr/store/main/main.do?oy=0") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}



import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var hasLoaded = false

    override func viewDidLoad() {
        super.viewDidLoad()

        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.rightAnchor.constraint(equalTo: view.rightAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            webView.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])

        loadWebView()
        configureBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)

        if !hasLoaded {
            loadWebView()
        }
    }
    
    func loadWebView() {
        if let url = URL(string: "https://www.oliveyoung.co.kr/") {
            let request = URLRequest(url: url)
            webView.load(request)
            hasLoaded = true
        }
    }

    func configureBackButton() {
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func backButtonTapped() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func shouldOpenInNewViewController(url: URL) -> Bool {
         let urlString = url.absoluteString
         if urlString.contains("/getPlanShopDetail.do") {
             return true
         } else if urlString.contains("/getGoodsDetail.do") {
             return true
         } else if urlString.contains("List.do") {
             return true
         }
         return false
     }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, navigationAction.navigationType == .linkActivated {
            print("Link clicked: \(url)")
            if shouldOpenInNewViewController(url: url) {
                let secondVC = SecondViewController()
                secondVC.url = url
                navigationController?.pushViewController(secondVC, animated: true)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Finished loading: \(webView.url?.absoluteString ?? "Unknown URL")")
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Failed to load: \(webView.url?.absoluteString ?? "Unknown URL") with error: \(error.localizedDescription)")
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let url = navigationResponse.response.url {
            print("Navigation response received for URL: \(url.absoluteString)")
            if shouldOpenInNewViewController(url: url) {
                let secondVC = SecondViewController()
                secondVC.url = url
                navigationController?.pushViewController(secondVC, animated: true)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
}

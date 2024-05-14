import UIKit
import WebKit

class GenericWebViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var url: URL?
    var lastLoadedURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

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
        
        if let url = url {
            loadWebView(url: url)
        } else {
            print("URL is nil")
        }
        
        configureBackButton()
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

    func loadWebView(url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
        lastLoadedURL = url
    }

    func shouldBlockURL(_ url: URL) -> Bool {
        guard let host = url.host else {
            return true
        }
        return !host.hasPrefix("m.oliveyoung.co.kr")
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if url.absoluteString == "about:blank" {
                decisionHandler(.cancel)
                return
            }
            print("Link clicked: \(url)")
            if shouldBlockURL(url) {
                decisionHandler(.cancel)
                return
            }
            if webView.url != url && lastLoadedURL != url {
                lastLoadedURL = url
                let newVC = GenericWebViewController()
                newVC.url = url
                navigationController?.pushViewController(newVC, animated: true)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
}

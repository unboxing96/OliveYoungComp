import UIKit
import WebKit

class SecondViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var url: URL?

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
            let request = URLRequest(url: url)
            webView.load(request)
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

    func shouldOpenInNewViewController(url: URL) -> Bool {
        let urlString = url.absoluteString
        if urlString == "https://www.oliveyoung.co.kr/" {
            return false
        } else if urlString.hasPrefix("https://www.oliveyoung.co.kr/") {
            return true
        }
        return false
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, navigationAction.navigationType == .linkActivated {
            print("Link clicked: \(url)")
            if shouldOpenInNewViewController(url: url) {
                let thirdVC = SecondViewController() // 새로운 SecondViewController 인스턴스를 생성하여 푸시
                thirdVC.url = url
                navigationController?.pushViewController(thirdVC, animated: true)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("SecondVC Started loading: \(webView.url?.absoluteString ?? "Unknown URL")")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("SecondVC Finished loading: \(webView.url?.absoluteString ?? "Unknown URL")")
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("SecondVC Failed to load: \(webView.url?.absoluteString ?? "Unknown URL") with error: \(error.localizedDescription)")
    }

    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("SecondVC Redirected to: \(webView.url?.absoluteString ?? "Unknown URL")")
    }
}

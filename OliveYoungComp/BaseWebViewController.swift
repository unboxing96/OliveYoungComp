//let refreshURLs: [String] = [
//    "https://m.oliveyoung.co.kr/m/mtn",
//    "https://m.oliveyoung.co.kr/m/mtn/shutter?t_page=%EC%85%94%ED%84%B0&t_click=%ED%99%88_%ED%83%AD%EB%B0%94_%EC%85%94%ED%84%B0",
//    "https://m.oliveyoung.co.kr/m/mtn/history?tab=recent",
//    "https://m.oliveyoung.co.kr/m/mypage/myPageMain.do",
//    "https://m.oliveyoung.co.kr/m/login/loginForm.do",
//    "https://m.oliveyoung.co.kr/m/cart/getCart.do?t_page=%ED%9E%88%EC%8A%A4%ED%86%A0%EB%A6%AC&t_click=%EC%9E%A5%EB%B0%94%EA%B5%AC%EB%8B%88",
//    
//]



import UIKit
import WebKit

class BaseWebViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var lastLoadedURL: URL?
    var initialLoadCompleted = false

    override func viewDidLoad() {
        super.viewDidLoad()
        configureWebView()
    }

    func configureWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.rightAnchor.constraint(equalTo: view.rightAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            webView.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])
    }

    func loadWebView(url: URL) {
        print("BaseWebViewController | loadWebView | currentUrl: \(url)")
        let request = URLRequest(url: url)
        webView.load(request)
//        lastLoadedURL = url
    }

    func shouldBlockURL(_ url: URL) -> Bool {
//        guard let host = url.host else { return true }
        if url.absoluteString == "about:blank" { return true }
        if url.absoluteString.contains("https://www.youtube.com/") { return true }
        if url.absoluteString.contains("https://gum.criteo.com/") { return true }
        return false
    }

    func shouldRefreshURL(_ url: URL) -> Bool {
        if url.absoluteString.contains("https://m.oliveyoung.co.kr/m/cart") { return true }
        
        let refreshURLs: [String] = [
            "https://m.oliveyoung.co.kr/m/mtn",
            "https://m.oliveyoung.co.kr/m/mtn?menu=home",
            "https://m.oliveyoung.co.kr/m/mtn/shutter?t_page=%EC%85%94%ED%84%B0&t_click=%ED%99%88_%ED%83%AD%EB%B0%94_%EC%85%94%ED%84%B0",
            "https://m.oliveyoung.co.kr/m/mtn/history?tab=recent",
            "https://m.oliveyoung.co.kr/m/mypage/myPageMain.do",
            "https://m.oliveyoung.co.kr/m/login/loginForm.do",
            "https://m.oliveyoung.co.kr/m/login/login.do",
            "https://m.oliveyoung.co.kr/m/mtn/history",
            "https://m.oliveyoung.co.kr/m/mtn/setting?t_page=%EB%A7%88%EC%9D%B4%ED%8E%98%EC%9D%B4%EC%A7%80&t_click=%EC%84%A4%EC%A0%95"
            
        ]
        return refreshURLs.contains(url.absoluteString)
    }

    func printNavigationStack() {
        guard let viewControllers = navigationController?.viewControllers else {
            print("No navigation controller or view controllers found.")
            return
        }

        print("Current navigation stack count: \(viewControllers.count)")
        for (index, viewController) in viewControllers.enumerated() {
            print("ViewController at index \(index): \(type(of: viewController))")
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        print("test url: \(url)")

        if initialLoadCompleted && url == lastLoadedURL {
            decisionHandler(.cancel)
            return
        }

        if shouldBlockURL(url) {
            print("BLOCK !!!!!!!!!!!!!!!!!")
            decisionHandler(.cancel)
            return
        }

        if initialLoadCompleted {
            if shouldRefreshURL(url) {
                decisionHandler(.allow)
                return
            } else {
                // 그 외의 경우 새로운 뷰컨트롤러를 푸시합니다
                print("BaseWebViewController | webView | initialLoadCompleted | url: \(url)")
                let newVC = GenericWebViewController()
                newVC.url = url
                navigationController?.pushViewController(newVC, animated: true)
                decisionHandler(.cancel)
            }

            printNavigationStack()
        } else {
            initialLoadCompleted = true
            decisionHandler(.allow)
        }

//        lastLoadedURL = url
    }
}

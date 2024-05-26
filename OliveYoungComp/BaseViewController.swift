import UIKit
import WebKit

class BaseViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("BaseViewController | override viewDidLoad")
        
        configureWebView()
        
        if !AppState.shared.initialLoadCompleted {
            loadInitialWebView()
            AppState.shared.initialLoadCompleted = true
        }
    }

    func configureWebView() {
        let contentController = WKUserContentController()
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = contentController
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.allowsBackForwardNavigationGestures = true
        webView.isInspectable = true
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
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func loadInitialWebView() {
        if let url = URL(string: "https://m.oliveyoung.co.kr/m/mtn") {
            loadWebView(url: url)
        }
    }

    func shouldBlockURL(_ url: URL) -> Bool {
        let blockedURLs = [
            "about:blank",
            "https://www.youtube.com/",
            "https://gum.criteo.com/",
            "https://player.vimeo.com/",
            "https://play.grip.show/",
            "https://grip-8c4ce.firebaseapp.com/",
            "https://livegrip.oliveyoung.co.kr/",
            "https://m.oliveyoung.co.kr/m/live/",
            "https://cf-images.oliveyoung.co.kr/",
            "https://image.oliveyoung.co.kr/",
            "https://*.avkit.apple.com/"
        ]
        
        return blockedURLs.contains { url.absoluteString.contains($0) }
    }

    func shouldRefreshURL(_ url: URL) -> Bool {
        if url.absoluteString.contains("https://m.oliveyoung.co.kr/m/cart") { return true }
        if url.absoluteString.contains("https://m.oliveyoung.co.kr/m/mtn/search?") { return true }
        
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

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        print("BaseViewController | decidePolicyFor | url: ")
        
        // 현재 요청된 URL이 바로 직전에 호출된 URL인 경우 -> 차단
        if let lastLoadedURL = AppState.shared.lastLoadedURL, lastLoadedURL == url {
            print("현재 요청된 URL이 바로 직전에 호출된 URL인 경우")
            decisionHandler(.cancel)
            return
        }

        // 차단해야 하는 URL인 경우 -> 차단
        if shouldBlockURL(url) {
            print("차단해야 하는 URL인 경우")
            decisionHandler(.cancel)
            return
        }

        // 새로고침 해야 하는 경우(탭바 등) -> push 하지 않고 페이지 이동 allow
        if shouldRefreshURL(url) {
            print("새로고침 해야 하는 경우(탭바 등)")
            decisionHandler(.allow)
            return
        }

        // stack에 push 해야 하는 경우
        print("stack에 push 해야 하는 경우")
        let newVC = GenericViewController()
        newVC.url = url
        self.navigationController?.pushViewController(newVC, animated: true)
        AppState.shared.lastLoadedURL = url // 마지막 로드된 URL 업데이트
        decisionHandler(.cancel) // 페이지 이동은 cancel
    }
}

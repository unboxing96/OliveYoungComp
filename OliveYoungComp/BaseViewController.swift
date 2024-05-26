import UIKit
import WebKit

class BaseViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var lastLoadedURL: URL?
    var initialLoadCompleted = false

    override func viewDidLoad() {
        configureWebView()
        super.viewDidLoad()
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
        let request = URLRequest(url: url)
        webView.load(request)
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
            "https://*.avkit.apple.com/" // 추가: AVKit 관련 URL
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
        
        // 현재 요청된 URL이 바로 직전에 호출된 URL인 경우 -> 차단
        if initialLoadCompleted && url == lastLoadedURL {
            decisionHandler(.cancel)
            return
        }
        
        // 차단해야 하는 URL인 경우 -> 차단
        if shouldBlockURL(url) {
            decisionHandler(.cancel)
            return
        }
        
        if initialLoadCompleted {
            // 새로고침 해야 하는 경우(탭바 등) -> push 하지 않고 페이지 이동 allow
            if shouldRefreshURL(url) {
                decisionHandler(.allow)
                return
            
            // stack에 push 해야 하는 경우
            } else {
                let newVC = GenericViewController()
                newVC.url = url
                self.navigationController?.pushViewController(newVC, animated: true)
                decisionHandler(.cancel) // 페이지 이동은 cancel
            }
        } else {
            initialLoadCompleted = true
            decisionHandler(.allow)
        }
    }
}

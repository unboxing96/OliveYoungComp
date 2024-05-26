import UIKit
import WebKit

class BaseViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var vcvm = ViewControllerViewModel()
ㅇ 
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

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isInitialLoad = false // 로드 완료 시 초기 로드 상태를 해제
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        // 초기 로드 시에는 navigationAction을 무시
        if isInitialLoad {
            decisionHandler(.allow)
            return
        }
        
        print("BaseViewController | decidePolicyFor | url: \(url)")

        // 현재 요청된 URL이 바로 직전에 호출된 URL인 경우 -> 차단
        if let lastLoadedURL = AppState.shared.lastLoadedURL, lastLoadedURL == url {
            print("현재 요청된 URL이 바로 직전에 호출된 URL인 경우")
            decisionHandler(.cancel)
            return
        }

        // 차단해야 하는 URL인 경우 -> 차단
        if vcvm.shouldBlockURL(url) {
            print("차단해야 하는 URL인 경우")
            decisionHandler(.cancel)
            return
        }

        // 새로고침 해야 하는 경우(탭바 등) -> push 하지 않고 페이지 이동 allow
        if vcvm.shouldRefreshURL(url) {
            print("새로고침 해야 하는 경우(탭바 등)")
            decisionHandler(.allow)
            return
        }

        // stack에 push 해야 하는 경우
        print("stack에 push 해야 하는 경우")
        let newVC = GenericViewController(url: url)
        self.navigationController?.pushViewController(newVC, animated: true)
        AppState.shared.lastLoadedURL = url // 마지막 로드된 URL 업데이트
        decisionHandler(.cancel) // 페이지 이동은 cancel
    }
}

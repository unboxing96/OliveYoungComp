import UIKit
import WebKit

class RootViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    
    var webView: WKWebView!
    var isInitialLoad: Bool = true // 초기 로드를 제어하는 플래그
    var vcvm = ViewControllerViewModel()
    
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
        contentController.add(self, name: "buttonClicked")
        
        let jsCode = """
        window.addEventListener('load', function() {
            function addClickListenerToLinks() {
                var searchButtonClass = 'SearchButton_search-button__R_86C';
                var basketButtonClass = 'BasketButton_basket-button___xAaP';

                var links = document.getElementsByTagName('a');
                Array.prototype.forEach.call(links, function(link) {
                    var linkClass = link.className;
                    var linkId = link.id;
                    
                    if (!link.getAttribute('data-event-attached') &&
                        (linkClass.includes(searchButtonClass) ||
                         linkClass.includes(basketButtonClass))) {
                        link.addEventListener('click', function(event) {
                            event.preventDefault(); // 기본 네비게이션 방지
                            var url = event.currentTarget.href;
                            window.webkit.messageHandlers.buttonClicked.postMessage({
                                action: 'navigate',
                                url: url
                            });
                        });
                        link.setAttribute('data-event-attached', 'true');
                    }
                });
            }

            addClickListenerToLinks();
            var observer = new MutationObserver(function(mutations) {
                mutations.forEach(function(mutation) {
                    if (mutation.addedNodes.length > 0) {
                        addClickListenerToLinks();
                    }
                });
            });
            observer.observe(document.body, { childList: true, subtree: true });
        });
        """

        let userScript = WKUserScript(source: jsCode, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(userScript)
        
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
            print("RootViewController | 현재 요청된 URL이 바로 직전에 호출된 URL인 경우")
            decisionHandler(.cancel)
            return
        }
        
        // 차단해야 하는 URL인 경우 -> 차단
        if vcvm.shouldBlockURL(url) {
            print("RootViewController | 차단해야 하는 URL인 경우")
            decisionHandler(.cancel)
            return
        }
    
        // 새로고침 해야 하는 경우(탭바 등) -> push 하지 않고 페이지 이동 allow
        if vcvm.shouldRefreshURL(url) {
            print("RootViewController | 새로고침 해야 하는 경우(탭바 등)")
            decisionHandler(.allow)
            return
        }
        
        print("RootViewController | stack에 push 해야 하는 경우")
        
        var modifiedURLString = url.absoluteString
        if !modifiedURLString.hasSuffix("&oy=0") {
            modifiedURLString += "&oy=0"
        }

        if let modifiedURL = URL(string: modifiedURLString) {
            let newVC = GenericViewController(url: modifiedURL)
            self.navigationController?.pushViewController(newVC, animated: true)
            AppState.shared.lastLoadedURL = modifiedURL // 마지막 로드된 URL 업데이트
            decisionHandler(.cancel) // 페이지 이동은 cancel
            return
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("RootViewController | userContentController | didReceive message")
        print("message.name: \(message.name)")
        print("message.body: \(message.body)")
        
        if message.name == "buttonClicked" {
            if let messageBody = message.body as? [String: Any],
               let action = messageBody["action"] as? String,
               action == "navigate",
               let urlString = messageBody["url"] as? String,
               let url = URL(string: urlString) {
                print("Received navigation message for URL: \(url)")
                
                let newVC = GenericViewController(url: url)
                self.navigationController?.pushViewController(newVC, animated: true)
            }
        }
    }
}

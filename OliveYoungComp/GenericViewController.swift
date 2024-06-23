import UIKit
import WebKit

class GenericViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    var webView: WKWebView!
    var url: URL?
    var isInitialLoad: Bool = true // 초기 로드를 제어하는 플래그
    var vcvm = ViewControllerViewModel()
    
    init(url: URL?) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWebView()
        if let url = url {
            loadWebView(url: url)
        } else {
            loadInitialWebView()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isMovingFromParent {
            webView.removeFromSuperview()
            webView.navigationDelegate = nil
            webView = nil
        }
    }
    
    func configureWebView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "navigationBarButtonHandler")
        contentController.add(self, name: "nextJSNavigationHandler")
        contentController.add(self, name: "webToAppHandler") // 추가
        
        let navigationBarButtonJsCode = """
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
                            event.preventDefault();
                            var url = event.currentTarget.href;
                            window.webkit.messageHandlers.navigationBarButtonHandler.postMessage({
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
        
        let webToAppJsCode = """
        function callAppMethod() {
            return new Promise((resolve, reject) => {
                window.webkit.messageHandlers.webToAppHandler.postMessage('requestData');
                window.handleAppResponse = function(response) {
                    if (response) {
                        resolve(response);
                    } else {
                        reject('No response from app');
                    }
                }
            });
        }

        callAppMethod().then(response => {
            console.log('Received response from app:', response);
        }).catch(error => {
            console.error('Error:', error);
        });
        """
        
        let nextJsCode = """
        (function() {
            const handleRouteChange = (url, { shallow }) => {
                if (shallow || url.includes('t_click=GNB') || url.includes('history')) return;

                const fullUrl = 'https://m.oliveyoung.co.kr' + url;
                window.webkit.messageHandlers.nextJSNavigationHandler.postMessage({
                    action: 'navigate',
                    url: fullUrl
                });

                // 기본 네비게이션 이동 방지
                window.next.router.events.emit('routeChangeError');
                throw 'routeChange aborted.';
            };

            if (window.next && window.next.router) {
                window.next.router.events.on('routeChangeStart', (url, options) => {
                    handleRouteChange(url, options);
                });

                window.addEventListener('beforeunload', function() {
                    window.next.router.events.off('routeChangeStart', handleRouteChange);
                });
            }
        })();
        """
        let navigationBarButtonUserScript = WKUserScript(source: navigationBarButtonJsCode, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let webToAppUserScript = WKUserScript(source: webToAppJsCode, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let nextJsNavigationHandlerUserScript = WKUserScript(source: nextJsCode, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        contentController.addUserScript(navigationBarButtonUserScript)
        contentController.addUserScript(nextJsNavigationHandlerUserScript)
        contentController.addUserScript(webToAppUserScript)
//        
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
            
        // 현재 요청된 URL이 바로 직전에 호출된 URL인 경우 -> 차단
        if let lastLoadedURL = AppState.shared.lastLoadedURL, lastLoadedURL == url {
            decisionHandler(.cancel)
            return
        }
        
        // 차단해야 하는 URL인 경우 -> 차단
        if vcvm.shouldBlockURL(url) {
            decisionHandler(.cancel)
            return
        }

        let modifiedURL = vcvm.addSuffixToMainBanner(url)
        let newVC = GenericViewController(url: modifiedURL)
        self.navigationController?.pushViewController(newVC, animated: true)
        AppState.shared.lastLoadedURL = modifiedURL // 마지막 로드된 URL 업데이트
        decisionHandler(.cancel) // 페이지 이동은 cancel
        return
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "navigationBarButtonHandler":
            if let messageBody = message.body as? [String: Any],
               let action = messageBody["action"] as? String,
               action == "navigate",
               let urlString = messageBody["url"] as? String,
               let url = URL(string: urlString) {
                let newVC = GenericViewController(url: url)
                self.navigationController?.pushViewController(newVC, animated: true)
            }
        case "nextJSNavigationHandler":
            if let messageBody = message.body as? [String: Any],
               let action = messageBody["action"] as? String,
               action == "navigate",
               let urlString = messageBody["url"] as? String,
               let url = URL(string: urlString) {
                if isInitialLoad {
                    return
                }

                let newVC = GenericViewController(url: url)
                self.navigationController?.pushViewController(newVC, animated: true)
            }
        case "webToAppHandler":
            if let messageBody = message.body as? String, messageBody == "requestData" {
                // 앱에서 특정한 case에 따라 웹으로 데이터를 전송
                var responseMessage: String
                
                // 특정 case에 따른 메시지 반환 예시
                switch AppState.shared.initialLoadCompleted {
                case true:
                    responseMessage = "Response for true"
                case false:
                    responseMessage = "Response for false"
                }
                
                let jsCode = "handleAppResponse('\(responseMessage)');"
                webView.evaluateJavaScript(jsCode, completionHandler: nil)
            }
        default:
            break
        }
    }
}

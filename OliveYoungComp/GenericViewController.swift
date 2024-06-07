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
    
    func configureWebView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "navigationBarButtonHandler")
        contentController.add(self, name: "reactPropsHandler")
        contentController.add(self, name: "historyHandler")
        contentController.add(self, name: "fetchHandler")
        
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
                            event.preventDefault(); // 기본 네비게이션 방지
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
        
        let addClickListenerToReactProps = """
        window.addEventListener('load', function() {
            function addClickListenerToLinks() {
                var links = document.getElementsByTagName('a');
                Array.prototype.forEach.call(links, function(link) {
                    if (!link.getAttribute('data-event-attached-react-props')) {
                        link.addEventListener('click', function(event) {
                            event.preventDefault(); // 기본 네비게이션 방지

                            console.log('Click event triggered');
                            var element = event.target;
                            var contentsUrl = null;

                            // Try to find contentsUrl in the event target's dataset
                            if (element.dataset.contentsurl) {
                                contentsUrl = element.dataset.contentsurl;
                                console.log('Found contentsUrl in dataset:', contentsUrl);
                            } else {
                                // Traverse up the DOM tree to find the dataset contentsurl
                                while (element) {
                                    if (element.dataset && element.dataset.contentsurl) {
                                        contentsUrl = element.dataset.contentsurl;
                                        console.log('Found contentsUrl in ancestor dataset:', contentsUrl);
                                        break;
                                    }
                                    element = element.parentElement;
                                }
                            }

                            if (contentsUrl) {
                                window.webkit.messageHandlers.reactPropsHandler.postMessage({
                                    action: 'navigate',
                                    url: contentsUrl
                                });
                            } else {
                                var url = event.currentTarget.href;
                                window.webkit.messageHandlers.reactPropsHandler.postMessage({
                                    action: 'navigate',
                                    url: url
                                });
                            }
                        });
                        link.setAttribute('data-event-attached-react-props', 'true');
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


        
        let historyJsCode = """
        (function(history){
            var pushState = history.pushState;

            history.pushState = function(state, title, url) {
                console.log('pushState called with URL:', url); // 로그 추가
                var result = pushState.apply(history, arguments);
                window.webkit.messageHandlers.historyHandler.postMessage({
                    action: 'navigate',
                    type: 'pushState',  // 이벤트 타입 추가
                    url: location.href
                });
                return;
            };
        })(window.history);
        """
        
        let fetchJsCode = """
        (function() {
            // Capture fetch requests
            var originalFetch = window.fetch;
            window.fetch = function() {
                return originalFetch.apply(this, arguments).then(function(response) {
                    var clonedResponse = response.clone();
                    clonedResponse.json().then(function(data) {
                        window.webkit.messageHandlers.fetchHandler.postMessage({
                            url: clonedResponse.url,
                            data: data
                        });
                    });
                    return response;
                });
            };

            // Capture XMLHttpRequest requests
            var originalXHR = XMLHttpRequest.prototype.open;
            XMLHttpRequest.prototype.open = function(method, url) {
                this.addEventListener('load', function() {
                    if (this.responseType === '' || this.responseType === 'json') {
                        window.webkit.messageHandlers.fetchHandler.postMessage({
                            url: url,
                            data: this.responseText
                        });
                    }
                });
                originalXHR.apply(this, arguments);
            };
        })();
        """

        let navigationBarButtonUserScript = WKUserScript(source: navigationBarButtonJsCode, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let addClickListenerToReactPropsScript = WKUserScript(source: addClickListenerToReactProps, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let historyUserScript = WKUserScript(source: historyJsCode, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let fetchUserScript = WKUserScript(source: fetchJsCode, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        contentController.addUserScript(navigationBarButtonUserScript)
        contentController.addUserScript(addClickListenerToReactPropsScript)
    //    contentController.addUserScript(historyUserScript)
    //    contentController.addUserScript(fetchUserScript)
        
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
        
        print("GenericViewController | decidePolicyFor | url: \(url)")
        
        // 현재 요청된 URL이 바로 직전에 호출된 URL인 경우 -> 차단
        if let lastLoadedURL = AppState.shared.lastLoadedURL, lastLoadedURL == url {
            print("GenericViewController | 현재 요청된 URL이 바로 직전에 호출된 URL인 경우")
            decisionHandler(.cancel)
            return
        }
        
        // 차단해야 하는 URL인 경우 -> 차단
        if vcvm.shouldBlockURL(url) {
            print("GenericViewController | 차단해야 하는 URL인 경우")
            decisionHandler(.cancel)
            return
        }
        
//        // 새로고침 해야 하는 경우(탭바 등) -> push 하지 않고 페이지 이동 allow
//        if vcvm.shouldRefreshURL(url) {
//            print("GenericViewController | 새로고침 해야 하는 경우(탭바 등)")
//            decisionHandler(.allow)
//            return
//        }
        
        // stack에 push 해야 하는 경우
        print("GenericViewController | stack에 push 해야 하는 경우")
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
        print("GenericViewController | userContentController | didReceive message")
        print("message.name: \(message.name)")
        print("message.body: \(message.body)")
        
        switch message.name {
        case "navigationBarButtonHandler":
            if let messageBody = message.body as? [String: Any],
               let action = messageBody["action"] as? String,
               action == "navigate",
               let urlString = messageBody["url"] as? String,
               let url = URL(string: urlString) {
                print("Received navigation message for URL: \(url)")

                let newVC = GenericViewController(url: url)
                self.navigationController?.pushViewController(newVC, animated: true)
            }
        case "reactPropsHandler":
            if let messageBody = message.body as? [String: Any],
               let action = messageBody["action"] as? String,
               action == "navigate",
               let urlString = messageBody["url"] as? String,
               let url = URL(string: urlString) {
                print("Received navigation message for URL: \(url)")

                let newVC = GenericViewController(url: url)
                self.navigationController?.pushViewController(newVC, animated: true)
            }
        case "historyHandler":
            if let messageBody = message.body as? [String: Any],
               let action = messageBody["action"] as? String,
               action == "navigate",
               let urlString = messageBody["url"] as? String,
               let url = URL(string: urlString) {
                print("Received navigation message for URL: \(url)")

                let newVC = GenericViewController(url: url)
                self.navigationController?.pushViewController(newVC, animated: true)
            }
        case "fetchHandler":
            if let messageBody = message.body as? [String: Any],
               let action = messageBody["action"] as? String,
               action == "navigate",
               let urlString = messageBody["url"] as? String,
               let url = URL(string: urlString) {
                    print("Received navigation message for URL: \(url)")
            }
        default:
            break
        }
    }
}

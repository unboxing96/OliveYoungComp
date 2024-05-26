import UIKit
import WebKit

class GenericViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var url: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("GenericViewController | override viewDidLoad | url: ")
        
        configureWebView()
        
        if let url = url {
            loadWebView(url: url)
        } else {
            print("URL is nil")
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
}

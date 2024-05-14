import UIKit
import WebKit

class ViewController: BaseWebViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
        loadInitialWebView()
    }
    
    func loadInitialWebView() {
        if let url = URL(string: "https://m.oliveyoung.co.kr/m/mtn") {
//            print("ViewController | loadInitialWebView | initialURL: \(url)")
            loadWebView(url: url)
        }
    }

    func configureBackButton() {
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func backButtonTapped() {
//        if webView.canGoBack {
//            webView.goBack()
//        } else {
            navigationController?.popViewController(animated: true)
//        }
    }
}

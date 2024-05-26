import UIKit
import WebKit

class GenericViewController: BaseViewController {
    var url: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
        
        if let url = url {
            loadWebView(url: url)
        } else {
            print("URL is nil")
        }
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
}

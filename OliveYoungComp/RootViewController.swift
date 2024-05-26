import UIKit
import WebKit

class RootViewController: NavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
        loadInitialWebView()
    }
    
    func loadInitialWebView() {
        if let url = URL(string: "https://m.oliveyoung.co.kr/m/mtn") {
            loadWebView(url: url)
        }
    }

    func configureBackButton() {
        let backButton = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

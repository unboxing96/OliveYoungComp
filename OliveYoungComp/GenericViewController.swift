import UIKit
import WebKit

class GenericViewController: NavigationController {
    var url: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureBackButton()
        
        if let url = url {
            loadWebView(url: url)
        } else {
            print("URL is nil")
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

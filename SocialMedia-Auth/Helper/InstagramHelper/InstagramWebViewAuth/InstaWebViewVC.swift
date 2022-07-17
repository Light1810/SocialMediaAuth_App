//
//  InstaWebView.swift
//  SocialMedia-Auth
//
//  Created by Aakash Decosta on 17/07/22.
//

import WebKit

protocol InstagramUserDelegate {
    func instagramUser(data: InstagramTestUser)
    func instagramError(error: Error)
}

class InstaWebViewVC: UIViewController {
    
    var instagramApi: InstagramHelper = InstagramHelper.shared
    var delegate: InstagramUserDelegate?
    @IBOutlet var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        instagramApi.authorizeApp { (url) in
        DispatchQueue.main.async {
            self.webView.load(URLRequest(url: url!))
        }
      }
    }

}

extension InstaWebViewVC {
    class func loadFromXIB() -> InstaWebViewVC? {
        let storyboard = UIStoryboard(name: "InstaWebView", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "InstaWebViewVC") as? InstaWebViewVC else {
            return nil
        }
        return viewController
    }
}

extension InstaWebViewVC : WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let request = navigationAction.request
        decisionHandler(WKNavigationActionPolicy.allow)
        self.instagramApi.getTestUserIDAndToken(request: request) { [weak self] (instagramTestUser) in
            switch instagramTestUser {
            case .success(let userData):
                self?.delegate?.instagramUser(data: userData)
                DispatchQueue.main.async {
                    self?.dismiss(animated: true) {
                    }
                }
            case .failure(let error):
                self?.delegate?.instagramError(error: error)
                DispatchQueue.main.async {
                    self?.dismiss(animated: true) {
                    }
                }
            }
           

        }
        
    }
}

//
//  ViewController.swift
//  SocialMedia-Auth
//
//  Created by Aakash Decosta on 16/07/22.
//

import UIKit
import AuthenticationServices

class SocialLoginVC: UIViewController {
    lazy var viewModel = SocialLoginViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func tappedFbLoginBtn(_ sender: UIButton) {
        viewModel.fbLogout()
        viewModel.fbAuthWithToken(in: self, completion: { (result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let token):
                print(token)
            }
        })
    }
    @IBAction func twitterLoginBtnAction(_ sender: UIButton) {
        viewModel.twitterLogout()
        viewModel.twitterLogin(in: self)
    }
    @IBAction func googleLoginBtnAction(_ sender: UIButton) {
        viewModel.googleSignOut()
        viewModel.googleSignIn(controller: self) { user, error in
            if error == nil {
                guard let accessToken =  user?.authentication.accessToken else { return }
                print(accessToken)
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    @IBAction func tappedAppleLoginBtn(_ sender: UIButton) {
        viewModel.appleLogin()
    }
    @IBAction func tappedInstaLoginBtn(_ sender: UIButton) {
        instagramLogin()
    }
    func instagramLogin() {
        guard let vc = InstaWebViewVC.loadFromXIB() else {
            return
        }
        vc.delegate = self
        present(vc, animated:true)
    }
}
extension SocialLoginVC: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window!
    }
}
extension SocialLoginVC : InstagramUserDelegate {
    func instagramUser(data: InstagramTestUser) {
        print(data.access_token)
    }
    func instagramError(error: Error) {
        print(error.localizedDescription)
    }
}

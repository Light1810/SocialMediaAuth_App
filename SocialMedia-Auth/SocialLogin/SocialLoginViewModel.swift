//
//  SocialLoginViewModel.swift
//  SocialMedia-Auth
//
//  Created by Aakash Decosta on 16/07/22.
//

import Foundation
import FacebookLogin
import Swifter
import AuthenticationServices
import GoogleSignIn

enum AuthError: String, Error {
    case fBAuthtokenNotFound = "FB Auth token not found."
    case fbAuthNoResult = "Facebook auth failed."
}

class SocialLoginViewModel: NSObject {
    
    override init() {
    }
    
}
// MARK: - Facebook Auth Functions
extension SocialLoginViewModel {
    func fbAuthWithToken(in controller: UIViewController, completion:@escaping (Result<String,Error>) -> Void) {
        if let token = AccessToken.current,
            !token.isExpired {
            // User is logged in, do work such as go to next view controller.
            print(token.tokenString)
            completion(.success(token.tokenString))
            // api call with this token
            // Login with string token
        } else {
            let fbLoginManager = LoginManager()
            fbLoginManager.logIn(permissions: ["public_profile", "email"], from: controller) { (result,error) in
                if let error = error {
                    print(error.localizedDescription)
                    completion(.failure(error))
                } else if let result = result {
                    guard let token = result.token?.tokenString else {
                        completion(.failure(AuthError.fBAuthtokenNotFound))
                        return
                    }
                    print(token)
                    completion(.success(token))
                    // api call with this token
                } else {
                    completion(.failure(AuthError.fbAuthNoResult))
                }
            }
        }
    }
    
    func fbLogout() {
        if let token = AccessToken.current,
            !token.isExpired {
            let fbLoginManager = LoginManager()
            fbLoginManager.logOut()
            // Login with string token
        }
    }
}
// MARK: - Twitter Auth Functions
extension SocialLoginViewModel {
    func twitterLogin(in controller: ASWebAuthenticationPresentationContextProviding) {
       if let data = KeychainHelper.standard.read(service: "access-token", account: "twitter"),
          let dataS = KeychainHelper.standard.read(service: "secret-token", account: "twitter"),
           let accessToken = String(data: data, encoding: .utf8),
           let secretToken = String(data: dataS, encoding: .utf8){
           print(accessToken)
           print(secretToken)
        // api call to login token already there
       } else {
           // token is not in keyChain
           let swifter = Swifter(consumerKey: TwitterConstants.CONSUMER_KEY, consumerSecret: TwitterConstants.CONSUMER_SECRET_KEY)
           swifter.authorize(withProvider: controller, callbackURL: URL(string: TwitterConstants.CALLBACK_URL)!) { oauth, _ in

               if let accessToken = oauth?.key,
                  let secretKey = oauth?.secret {
                   let data = Data(accessToken.utf8)
                   let dataS = Data(secretKey.utf8)
                   KeychainHelper.standard.save(data, service: "access-token", account: "twitter")
                   KeychainHelper.standard.save(dataS, service: "secret-token", account: "twitter")
                   // api call to login token already there
               }
           }
       }
    }
    
    func twitterLogout() {
        // api call to send token to backend for invalidation
        KeychainHelper.standard.delete(service: "access-token", account: "twitter")
        KeychainHelper.standard.delete(service: "secret-token", account: "twitter")
    }
}
// MARK: - Google Auth Functions
extension SocialLoginViewModel {
    func googleSignIn(controller: UIViewController,completion: @escaping (_ user: GIDGoogleUser?,_ error: Error?) -> Void) {
        let clientID = GoogleConstants.CLIENT_ID
        let signInConfig = GIDConfiguration.init(clientID: clientID)
        if let currentUser = GIDSignIn.sharedInstance.currentUser{
            completion(currentUser, nil)
            
        } else {
            GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: controller) { user, error in
                completion(user, error)
                // If sign in succeeded, display the app's main content View.
            }
        }
     
        
    }
    
    func googleSignOut(){
        GIDSignIn.sharedInstance.signOut()
    }
}
// MARK: - Apple Auth Functions
extension SocialLoginViewModel {
    func appleLogin(){
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
}
extension SocialLoginViewModel:  ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
            if let idToken = appleIDCredential.identityToken ,
               let _ = appleIDCredential.email,
               let _ = appleIDCredential.fullName?.givenName,
               let accessToken = String(data: idToken, encoding: .utf8) {
                print(accessToken)
               // make api call with string token
            }

        }
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
    }
}

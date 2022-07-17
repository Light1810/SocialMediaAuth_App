//
//  InstagramHelper.swift
//  SocialMedia-Auth
//
//  Created by Aakash Decosta on 17/07/22.
//

import Foundation

class InstagramHelper {
    
    static let shared = InstagramHelper()
    private let client_id = InstagramConstants.APP_ID
    private let baseUrl = "https://api.instagram.com/oauth/authorize"
    private let redirectURI = InstagramConstants.REDIRECT_URI
    private let app_secret = InstagramConstants.APP_SECRET
    private let scope = "user_profile"
    private let response_type = "code"
    private let authURL = "https://api.instagram.com/oauth/access_token"
    private let dataUrl = "https://graph.instagram.com/"
    
    private init () {}
    
    func authorizeApp(completion: @escaping (_ url: URL?) -> Void ) {
        let urlString = "\(baseUrl)?client_id=\(client_id)&redirect_uri=\(redirectURI)&scope=\(scope)&response_type=\(response_type)"
        let request = URLRequest(url: URL(string: urlString)!)
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if let response = response {
                completion(response.url)
            }
        })
        task.resume()
    }
    
    private func getTokenFromCallbackURL(request: URLRequest) -> String? {
        let requestURLString = (request.url?.absoluteString)! as String
        if requestURLString.starts(with: "\(redirectURI)?code=") {
            if let range = requestURLString.range(of: "\(redirectURI)?code=") {
                return String(requestURLString[range.upperBound...].dropLast(2))
            }
        }
        return nil
    }
    
    func getTestUserIDAndToken(request: URLRequest, completion: @escaping (Result<InstagramTestUser,Error>) -> Void){
      guard let authToken = getTokenFromCallbackURL(request: request) else {
      return
      }
        getNewAccessToken(authToken: authToken) { (response) in
            switch response {
            case.success(let user):
                print(user)
                completion(.success(user))
            case .failure(let error):
                print(error.localizedDescription)
                completion(.failure(error))
            }
           
           
        }
    }

    
    //Fetch Refresh Token API
    func getNewAccessToken(authToken:String , completion: @escaping(_ reponse: Result<InstagramTestUser,Error>)-> Void) {
        let headers = ["Accept": "application/json",
                       "Content-Type": "application/x-www-form-urlencoded"]
        let parameters = ["client_id": client_id, "app_secret": app_secret, "grant_type" :"authorization_code" ,"redirect_uri":redirectURI ,"code" : authToken]
        print(authURL)
        InstaAPIManager.shared.postData(url: authURL, parameters: parameters, headers: headers, resposne: InstagramTestUser.self) { result in
            switch result {
            case .success(let user):
                print(user)
                completion(.success(user))
            case .failure(let error):
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    func getUserData(uid:Int,token: String , completion: @escaping(_ reponse: Result<UserData,Error>)-> Void) {
        let headers = ["Accept": "application/json",
                       "Content-Type": "application/json"]
        let parameters = ["access_token": token , "fields" :"username"]
        InstaAPIManager.shared.getData(url:  dataUrl + "\(uid)", parameters: parameters, headers: headers,resposne: UserData.self){ (result) in
            switch result {
            case .success(let user):
                print(user)
                completion(.success(user))
            case .failure(let error):
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
}

//
//  InstaAPIManager.swift
//  NewsApp
//
//  Created by Aakash Decosta on 13/07/22.
//

import Foundation

class InstaAPIManager {
    
    static let shared = InstaAPIManager()
    
    func getData<T: Codable>(url: String,parameters:[String: String], headers: [String: String] ,resposne:T.Type, completion: @escaping (Result<T,Error>) -> Void) {
        var urlComponent = URLComponents(string: url)!
        urlComponent.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        print( urlComponent.url!)
        var request = URLRequest(url:  urlComponent.url!)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response , error in
            
            do {
                let model =  try JSONDecoder().decode(T.self, from: data!)
                completion(.success(model))
            } catch {
                print(error)
                completion(.failure(error))
            }
        })
        task.resume()
    }
    
    func postData<T: Codable>(url: String,parameters:[String: Any], headers: [String: String] ,resposne:T.Type, completion: @escaping (Result<T,Error>)-> Void) {
        let urlComponent = URLComponents(string: url)!
        var request = URLRequest(url: urlComponent.url!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = parameters.percentEncoded()

        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let encoder = JSONEncoder()
            if let jsonData = try? encoder.encode(data) {
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print(jsonString)
                }
            }
            do {
                let model =  try JSONDecoder().decode(T.self, from: data)
                completion(.success(model))
            } catch {
                print(error)
                completion(.failure(error))
            }
        }

        task.resume()
    }
    
}

extension Dictionary {
    func percentEncoded() -> Data? {
        map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed: CharacterSet = .urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}



struct InstagramTestUser: Codable {
    var access_token: String
    var user_id: Int
}

struct InstagramAccessTokenBody : Codable {
    var client_id : Int
    var client_secret : String
    var grant_type : String
    var redirect_uri : String
    var code : String
}

struct UserData: Codable {
    let username, id: String
}

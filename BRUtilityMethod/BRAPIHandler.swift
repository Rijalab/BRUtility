//
//  BRAPIHandler.swift
//  BRUtilityMethod
//
//  Created by Balaji Ramakrishnan on 11/10/18.
//  Copyright © 2018 rijalab. All rights reserved.
//

import UIKit
import Foundation
import Reachability
import SVProgressHUD

enum API_Method: String {
    case Get = "GET"
    case Post = "POST"
    case Delete = "DELETE"
    case Put = "PUT"
}

class BRAPIHandler: NSObject {
    
    static let sharedInstance: BRAPIHandler = {
        let instance = BRAPIHandler()
        return instance
    }()
    
    func reachabilityCheck() -> Bool {
        let reachability = Reachability()!
        return reachability.connection != .none
    }
    
    func showProgressLoader(view : UIView?) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        SVProgressHUD.show(with: .black)
    }
    
    func hideProgressLoader(view : UIView?) {
        UIApplication.shared.endIgnoringInteractionEvents()
        SVProgressHUD.dismiss()
    }
    
    typealias APICompletionHandler = (Bool, [String:Any]?, Data?, Int) -> Void
    
    //MARK:- Request to Call API
    
    func initWithAPIUrl(_ urlString: String, method: API_Method, params: [String:Any]?, currentViewController: UIViewController?, progressView:UIView?, completionHandler: @escaping APICompletionHandler) {
        
        if self.reachabilityCheck() { // Need to check Reachability
            
            if progressView != nil {
                DispatchQueue.main.async {
                    self.showProgressLoader(view: progressView)
                }
            }
            
            guard let url: URL = URL(string: urlString) else {
                completionHandler(false,nil,nil,0)
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            
            if let param = params{
                if param.keys.contains("multipartFileData"){
                    // Multipart form data
                    if let data = param["multipartFileData"] as? Data{
                        request.addValue("multipart/form-data; boundary=\(param["boundary"] as? String ?? "")", forHTTPHeaderField: "Content-Type")
                        request.httpBody = data
                    }
                }
                else if method == .Get {
                    /// If Params sent in GET method, it will load as QueryParameter.
                    var urlComponents = URLComponents(string: url.absoluteString)
                    
                    if let dict = params {
                        
                        var queryParams = [URLQueryItem]()
                        
                        for (key,value) in dict {
                            let queryParam = URLQueryItem(name: key, value: value as? String ?? "")
                            queryParams.append(queryParam)
                        }
                        
                        urlComponents?.queryItems = queryParams
                        if let url = urlComponents?.url {
                            request = URLRequest(url: url)
                            request.httpMethod = method.rawValue
                        }
                    }
                }
                else{
                    // POST
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = try? JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
                }
            }
            else{
                // GET
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            self.apiCallWithRequest(request: request, progressView: progressView, completionHandler: { (success, responseDictionary, responseData, httpStatusCode) in
                completionHandler(success, responseDictionary, responseData, httpStatusCode)
            })
        }
        else{
            DispatchQueue.main.async(execute: {
                if let cVC = currentViewController {
                    cVC.showAlertViewController(withTitle: "No Internet", message: "Please check your internet connection and try again", autoHide: true)
                }
            })
        }
    }
    
    //MARK:- API Call
    
    private func apiCallWithRequest(request: URLRequest, progressView:UIView?, completionHandler: @escaping APICompletionHandler){
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if progressView != nil {
                    self.hideProgressLoader(view: progressView)
                }
            }
            
            guard let code = (response as? HTTPURLResponse)?.statusCode else {
                return
            }
            
            guard let data = data, error == nil else {
                print("error=\(error?.localizedDescription ?? "")")
                completionHandler(false, nil, nil, code)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers ) as? [String: Any] {
                    
                    #if debug
                    debugPrint("URL \(url) \nJSON \(json)")
                    #endif
                    
                    DispatchQueue.main.async(execute: {
                        completionHandler(true, json as Dictionary<String, Any>, data, code)
                    })
                }
                
            } catch let error {
                
                print("error..desc\(error.localizedDescription)")
                
                DispatchQueue.main.async(execute: {
                    completionHandler(false, nil, nil, code)
                })
            }
        }.resume()
    }
}

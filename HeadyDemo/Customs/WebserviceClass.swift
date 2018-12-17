//
//  WebserviceClass.swift
//

import Foundation
import UIKit
import MBProgressHUD
import Alamofire

class WebserviceClass {
    
    func firePostRequest(functionName : String,
                         requestDictionary : [String:Any]?,
                         shouldShowLoader : Bool,
                         vc : UIViewController?,
                         completion: ((Any?, HTTPURLResponse?, Error?) -> ())? = nil) {
        
        if isNetworkReachable(vc: vc) {
            if shouldShowLoader {
                showProgressHud(vc: vc)
            }
            
            let serverUrl = DynamicAPI.shared.getBaseApiUrl()
            if let url = URL(string: serverUrl + "/" + functionName) {
                
                if requestDictionary != nil {
                    print("REQUEST - (" + functionName + ") : " + requestDictionary!.description)
                }
                
                Alamofire.request(url,
                                  method: .post,
                                  parameters: requestDictionary,
                                  encoding: JSONEncoding.default,
                                  headers: nil).responseJSON(completionHandler: { (response) in
                                    if shouldShowLoader {
                                        self.dismissProgressHud(vc: vc)
                                    }
                                    print("RESPONSE - (" + functionName + ") : " + response.result.value.debugDescription)
                                    DispatchQueue.main.async {
                                        completion?(response.result.value, response.response, response.error)
                                    }
                                  })
            }
        }
    }
    
    func postRequest(urlString : String,
                     requestDictionary : [String:Any]?,
                     shouldShowLoader : Bool,
                     vc : UIViewController?,
                     completion: ((Any?, HTTPURLResponse?, Error?) -> ())? = nil) {
        
        if isNetworkReachable(vc: vc) {
            if shouldShowLoader {
                showProgressHud(vc: vc)
            }
            if let url = URL(string: urlString) {
                
                if requestDictionary != nil {
                    print("REQUEST - (" + urlString + ") : " + requestDictionary!.description)
                }
                
                Alamofire.request(url,
                                  method: .post,
                                  parameters: requestDictionary,
                                  encoding: JSONEncoding.default,
                                  headers: nil).responseJSON(completionHandler: { (response) in
                                    if shouldShowLoader {
                                        self.dismissProgressHud(vc: vc)
                                    }
                                    print("RESPONSE - (" + urlString + ") : " + response.result.value.debugDescription)
                                    DispatchQueue.main.async {
                                        completion?(response.result.value, response.response, response.error)
                                    }
                                  })
                
            }
        }
    }
    
    func fireGetRequest(functionName : String,
                        requestDictionary : [String:Any]?,
                        shouldShowLoader : Bool,
                        vc : UIViewController?,
                        completion: ((Any?, URLResponse?, Error?) -> ())? = nil) {
        
        if isNetworkReachable(vc: vc) {
            if shouldShowLoader {
                showProgressHud(vc: vc)
            }
            let serverUrl = DynamicAPI.shared.getBaseApiUrl()
            if let url = URL(string: serverUrl + functionName) {
                if requestDictionary != nil {
                    print("REQUEST - (" + functionName + ") : " + requestDictionary!.description)
                }
                
                Alamofire.request(url,
                                  method: .get,
                                  parameters: requestDictionary,
                                  encoding: JSONEncoding.default,
                                  headers: nil).responseJSON(completionHandler: { (response) in
                                    print("RESPONSE - (" + functionName + ") : " + response.result.value.debugDescription)
                                    if shouldShowLoader {
                                        self.dismissProgressHud(vc: vc)
                                    }
                                    DispatchQueue.main.async {
                                        completion?(response.result.value, response.response, response.error)
                                    }
                                  })
            }
        }
    }
    
    func getRequest(urlString : String,
                    requestDictionary : [String:Any]?,
                    shouldShowLoader : Bool,
                    vc : UIViewController?,
                    completion: ((Any?, HTTPURLResponse?, Error?) -> ())? = nil) {
        
        if isNetworkReachable(vc: vc) {
            if shouldShowLoader {
                showProgressHud(vc: vc)
            }
            if let url = URL(string: urlString) {
                
                if requestDictionary != nil {
                    print("REQUEST - (" + urlString + ") : " + requestDictionary!.description)
                }
                
                Alamofire.request(url,
                                  method: .get,
                                  parameters: requestDictionary,
                                  encoding: JSONEncoding.default,
                                  headers: nil).responseJSON(completionHandler: { (response) in
                                    if shouldShowLoader {
                                        self.dismissProgressHud(vc: vc)
                                    }
                                    print("RESPONSE - (" + urlString + ") : " + response.result.value.debugDescription)
                                    DispatchQueue.main.async {
                                        completion?(response.result.value, response.response, response.error)
                                    }
                                  })
                
            }
        }
    }
    
    func getPostString(params:[String:Any]) -> String {
        var data = [String]()
        for(key, value) in params
        {
            data.append(key + "=\(value)")
        }
        return data.map { String($0) }.joined(separator: "&")
    }
    
    func showProgressHud(vc : UIViewController?){
        if vc != nil {
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                MBProgressHUD.showAdded(to: vc!.view, animated: true)
            }
        }
    }
    
    func dismissProgressHud(vc : UIViewController?){
        if vc != nil {
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                MBProgressHUD.hide(for: vc!.view, animated: true)
            }
        }
    }
    
    
    func isNetworkReachable(vc : UIViewController?) -> Bool {
        if let controller = vc {
            if let networkManager = NetworkReachabilityManager() {
                if networkManager.isReachable {
                    return true
                }
            }
            Global.shared.showNoNetworkAlert(vc: controller)
        }
        return false
    }
    
}



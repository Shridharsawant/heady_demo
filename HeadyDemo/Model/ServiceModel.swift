//
//  ServiceModel.swift
//  UTSupervisor
//
//  Created by Shridhar Sawant on 24/07/18.
//  Copyright © 2018 Plextiech. All rights reserved.
//

import Foundation
import Alamofire

class ServiceModel : NSObject {
    
    func getProducts(url : String,
                     controller : UIViewController?,
                     completion: ((Any?, URLResponse?, Error?) -> ())? = nil) {
        
        let webserviceClass = WebserviceClass()
        webserviceClass.getRequest(urlString: url,
                                   requestDictionary: nil,
                                   shouldShowLoader: true,
                                   vc: controller,
                                   completion: completion)
    }
}

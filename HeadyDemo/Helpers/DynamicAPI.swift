//
//  DynamicAPI.swift
//  UTSupervisor
//
//  Created by Shridhar Sawant on 24/07/18.
//  Copyright © 2018 Plextiech. All rights reserved.
//

import Foundation

class DynamicAPI: NSObject {
    
    @objc static let shared = DynamicAPI()
    
    @objc func getBaseApiUrl() -> String {
        return (IS_TESTING_MODE) ? TEST_URL : LIVE_URL
    }
    
}

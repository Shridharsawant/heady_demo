//
//  Constants.swift
//  UTSupervisor
//
//  Created by Shridhar Sawant on 13/07/18.
//  Copyright © 2018 Plextiech. All rights reserved.
//

import Foundation
import UIKit


let APP_DELEGATE                                    = UIApplication.shared.delegate as! AppDelegate
let IS_TESTING_MODE                                 = false
let THEME_COLOR                                     = UIColor(red: 0.0/255.0, green: 53.0/255.0, blue: 115.0/255.0, alpha: 1.0)
let STATUS_BAR_COLOR                                = UIColor(red: 0.0/255.0, green: 44.0/255.0, blue: 96.0/255.0, alpha: 1.0)
let USER_DEFAULTS                                   = UserDefaults.standard
let STANDARD_DATE_FORMAT                            = "MM/dd/yyyy HH:mm"
let DEFAULT_DATE_FORMAT                             = "MM/dd/yyyy"
let DEFAULT_TIME_FORMAT                             = "HH:mm"
let DEFAULT_ANIMATION_DURATION                      = 0.4
let GOOGLE_DOMAIN_URL                               = "https://maps.googleapis.com"
let MAP_BASE_URL                                    = "/maps/api/directions/json?"

let BOOKING_OBJECT_KEY                              = "bookingObject"
let SELECTION_OBJECT_KEY                            = "selectionObject"
let SELECTION_TYPE_KEY                              = "selectionType"



//RESPONSE CODES

let CODE_SUCCESS                                    = 100
let CODE_EXISTS                                     = 101
let CODE_ERROR                                      = 102
let CODE_NOT_FOUND                                  = 103


// STORYBOARD IDENTIFIERS

let LOGIN_STORYBOARD                                = "Login"
let HOME_STORYBOARD                                 = "Home"
let FARE_STORYBOARD                                 = "Fare"
let TRACKING_STORYBOARD                             = "Tracking"
let MISC_STORYBOARD                                 = "Misc"


// NIB NAMES

let RATE_DIALOG_NIB                                 = "RateDialogVC"

// VIEW CONTROLLER IDENTIFIERS

let CATEGORIES_VC_IDENTIFIER                        = "CategoriesVC"
let PRODUCT_LIST_VC_IDENTIFIER                      = "ProductListVC"
let PRODUCT_VC_IDENTIFIER                           = "ProductVC"

// CELL IDENTIFIERS

let CATEGORY_PARENT_TVC                             = "categoryParentCellIdentifier"
let CATEGORY_CHILD_TVC                              = "categoryChildCellIdentifier"
let PRODUCT_TVC_IDENTIFIER                          = "productTVCIdentifier"


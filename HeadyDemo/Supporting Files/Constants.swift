//
//  Constants.swift
//  UTSupervisor
//
//  Created by Shridhar Sawant on 13/07/18.
//  Copyright © 2018 Plextiech. All rights reserved.
//

import Foundation
import UIKit


// keys

let GOOGLE_MAP_API_KEY                              = "AIzaSyCJPv-zQqnxqkFA92g9LTOpztHH5jQ3Hxs"
let ENCRYPTION_KEY                                  = "UTGoPlexi"

// Constants

let PARTNER_ID                                      = 4456//4441//4441//4451
let APP_TYPE                                        = 1

let APP_DELEGATE                                    = UIApplication.shared.delegate as! AppDelegate
let IS_TESTING_MODE                                 = false
let THEME_COLOR                                     = UIColor(red: 0.0/255.0, green: 53.0/255.0, blue: 115.0/255.0, alpha: 1.0)
let STATUS_BAR_COLOR                                = UIColor(red: 0.0/255.0, green: 44.0/255.0, blue: 96.0/255.0, alpha: 1.0)
let USER_DEFAULTS                                   = UserDefaults.standard
let STANDARD_DATE_FORMAT                            = "MM/dd/yyyy HH:mm"
let DEFAULT_DATE_FORMAT                             = "MM/dd/yyyy"
let DEFAULT_TIME_FORMAT                             = "HH:mm"
let DEFAULT_ANIMATION_DURATION                      = 0.4
let IMAGE_BASE_URL                                  = "https://reservations.goldentouchofny.com/"
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
let HOME_NC_IDENTIFIER                              = "HomeNC"
let TRACK_VC_IDENTIFIER                             = "TrackVC"
let WEB_VC_IDENTIFIER                               = "WebViewController"
let MILES_STOPS_VC                                  = "MilesStopViewController"
let AGENCY_VC                                       = "ServiceProviderVC"

// CELL IDENTIFIERS

let CATEGORY_PARENT_TVC                             = "categoryParentCellIdentifier"
let SCHEDULE_CELL_IDENTIFIER                        = "scheduleCellIdentifier"
let FIND_FARE_CELL_IDENTIFIER                       = "findFareCellIdentifier"
let TRIP_DETAIL_CELL_IDENTIFIER                     = "tripDetailCellIdentifier"
let FIND_MY_RIDE_CELL_IDENTIFIER                    = "findMyRideCellIdentifier"

// NOTIFICATION NAMES

let NC_REFRESH_ROUTE_LIST                           = "refreshRouteList"

// nib NAMES

let BOOKING_SUCCESS_NIB                             = "BookingSuccessPopup"


let SCREEN_BOUNDS                                   = UIScreen.main.bounds

//URLSs

let GOOGLE_DIRECTION_BASE_URL                       = "https://maps.googleapis.com/maps/api/directions/json"

let FAQ_URL                                         = "http://www.utwiz.com/App/gofaq.html"
let TERMS_AND_CONDITION_URL                         = "http://www.utwiz.com/App/TermsConditions.html"
let PRIVACY_POLICY_URL                              = "http://www.utwiz.com/App/Privacy.html"


//STORYBOARDS

let MAIN_STORYBOARD                                 = "Main"
let OK_STORYBOARD                                   = "storyboard_ok"

//CONTROLLERS

let FIND_MY_RIDE_CONTROLLER                         = "FindMyRideViewController"
let FAVOURITE_VC                                    = "FavoutireVC"
let ROOT_CONTROLLER                                 = "rootController"
let SERVICE_PROVIDER_VC                             = "ServiceProviderVC"
let TOUR_VC                                         = "TourViewController"
let TAB_VC                                          = "TabVC"
let ROOT_NC                                         = "RootNC"
let MORE_TVC                                        = "MoreTVC"
let FEEDBACK_VC                                     = "RateViewController"
let SETTINGS_VC                                     = "SettingsViewController"
let ABOUT_VC                                        = "AboutViewController"
let SERVICE_NC                                      = "ServiceNC"


//NIB NAMES

let SERVICE_PROVIDER_NIB                            = "ServiceProviderView"
let SCHEDULES_NIB                                   = "SchedulesView"


//CELL IDENTIFIERS

let SERVICE_PROVIDER_CELL_IDENTIFIER                = "ServiceProviderCVC"
let PROFILE_CELL_IDENTIFIER                         = "profileCellIdentifier"
let SETTINGS_CELL_IDETIFIER                         = "settingsCellIdentifier"




//GOOGLE KEYS

let GOOGLE_MAP_TEST_API_KEY                         = "AIzaSyCJPv-zQqnxqkFA92g9LTOpztHH5jQ3Hxs"//AIzaSyCUQhqCnmk_dphk1eYorT9gOl5cs8BjaFk

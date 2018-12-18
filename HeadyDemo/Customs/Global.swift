//
//  Global.swift
//  UTGo
//
//  Created by Shridhar Sawant on 16/09/17.
//  Copyright © 2017 Plexitech. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import SDWebImage

class Global : NSObject {
    
    @objc static let shared = Global()
    
    @objc func showAlert(message : String, vc : UIViewController) {
        showAlert(title: Global.shared.getAppName(), message: message, vc: vc)
    }
    
    func showNoNetworkAlert(vc : UIViewController) {
        showAlert(message: "No internet connection detected, please reconnect and try again.", vc: vc)
    }
    
    @objc func showAlert(title : String, message : String, vc : UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(okAction)
        vc.present(alert, animated: true, completion: nil)
    }
    
    func getStatusBarHeight() -> CGFloat {
        let height = UIApplication.shared.statusBarFrame.height
        return height
    }
    
    func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return ""
    }
    
    func getOsVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    @objc func call(_ number : String) {
        if number != "" {
            var callNumber = number.replacingOccurrences(of: " ", with: "")
            callNumber = callNumber.replacingOccurrences(of: "-", with: "")
            callNumber = callNumber.replacingOccurrences(of: "(", with: "")
            callNumber = callNumber.replacingOccurrences(of: ")", with: "")
            if let url = URL(string: "tel://\(callNumber)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    func loadImageIntoImageView(stringUrl : String?, imageView : UIImageView) {
        loadImageIntoImageView(stringUrl: stringUrl,
                               imageView: imageView,
                               placeHolder: nil)
    }
    
    func loadImageIntoImageView(stringUrl : String?, imageView : UIImageView, placeHolder : UIImage?) {
        if stringUrl != nil && stringUrl != "" {
            if let url = URL(string: stringUrl!) {
                imageView.sd_setIndicatorStyle(.gray)
                imageView.sd_setImage(with: url,
                                      placeholderImage: placeHolder,
                                      options: [],
                                      progress: nil,
                                      completed: nil)
            }
        }
    }
    
    @objc func removeAllUserDefaults() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        /*let defs = UserDefaults.standard
        let dict = defs.dictionaryRepresentation()
        for key in dict.keys {
            if (key != UD_REMEMBER_ME &&
                key != UD_INTRO_SHOWN) &&
                key != UD_USER_NAME &&
                key != UD_PASSWORD
            {
                defs.removeObject(forKey: key)
            }
        }
        if !defs.bool(forKey: UD_REMEMBER_ME) {
            defs.removeObject(forKey: UD_USER_NAME)
            defs.removeObject(forKey: UD_PASSWORD)
        }*/
    }
    
    @objc func convertBase64toUIImage(base64String : String) -> UIImage? {
        if let data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) {
            let image = UIImage(data: data)
            return image
        }
        return nil
    }
    
    func getCurrentTime() -> String {
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        let currentTime = dateFormatter.string(from: today)
        return currentTime
    }
    
    func convertDateToString(date : Date, format : String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let myString = formatter.string(from: date)
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = format
        let myStringafd = formatter.string(from: yourDate!)
        return myStringafd
    }
    
    func convertDateToStringWithUTC(date : Date, format : String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let myString = formatter.string(from: date)
        let yourDate = formatter.date(from: myString)
        if let timeZone = TimeZone(identifier: "UTC") {
            formatter.timeZone = timeZone
        }
        formatter.dateFormat = format
        let myStringafd = formatter.string(from: yourDate!)
        return myStringafd
    }
    
    func convertStringToDate(dateString : String, dateFormat : String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        if let date = dateFormatter.date(from:dateString) {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
            let finalDate = calendar.date(from:components)
            return finalDate
        }
        return nil
    }
    
    @objc func getAppName() -> String {
        return Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

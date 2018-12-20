//
//  Extensions.swift
//  UTSupervisor
//
//  Created by Shridhar Sawant on 16/07/18.
//  Copyright © 2018 Plextiech. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func customCornerRadius(radius : CGFloat, roundingCorners : UIRectCorner) {
        let path = UIBezierPath(roundedRect:bounds,
                                byRoundingCorners:roundingCorners,
                                cornerRadii: CGSize(width: radius, height:  radius))
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
}

extension UIViewController {
    func showAlert(message : String) {
        let alert = UIAlertController(title: Global.shared.getAppName(),
                                      message: message,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

extension UIApplication {
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}

extension Double {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

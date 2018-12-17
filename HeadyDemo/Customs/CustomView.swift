//
//  CustomView.swift
//  UTGo
//
//  Created by Shridhar Sawant on 15/09/17.
//  Copyright © 2017 Plexitech. All rights reserved.
//
import Foundation
import UIKit

extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            let color = UIColor(cgColor: layer.borderColor!)
            return color
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.masksToBounds = false
            layer.shadowRadius = newValue
            layer.shadowColor = UIColor.darkGray.cgColor
            layer.shadowOffset = CGSize.zero
            layer.shadowOpacity = 0.8
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor {
        get {
            return UIColor(cgColor: layer.shadowColor ?? UIColor.clear.cgColor)
        }
        set {
            layer.masksToBounds = false
            layer.shadowColor = newValue.cgColor
            layer.shadowOffset = CGSize.zero
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.masksToBounds = false
            layer.shadowOpacity = newValue
        }
    }
}


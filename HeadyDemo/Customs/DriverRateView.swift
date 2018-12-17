//
//  DriverRateView.swift
//  UTGo
//
//  Created by Shridhar Sawant on 05/10/18.
//  Copyright © 2018 Plexitech. All rights reserved.
//

import Foundation
import UIKit

@objc protocol DriverRateViewDelegate : class {
    func rateViewDidChangeRating(rateView : DriverRateView, rating : Int)
}

class DriverRateView: UIView {
    
    let unselectedImage = UIImage(named: "star_unselected")
    let selectedImage = UIImage(named: "star_selected")
    
    var rating = 0
    var editable = true
    var imageViews = [UIImageView]()
    var maxRating : CGFloat = 5
    var midMargin : CGFloat = 10.0
    var sideMargin : CGFloat = 10.0
    @objc var delegate : DriverRateViewDelegate?
    var minImageSize = CGSize(width: 10, height: 10)
    var shouldChangeStarColors = false
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        baseInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        baseInit()
    }
    
    func baseInit() {
        imageViews.removeAll()
        delegate = nil
        setMaxRating(maxRating: Int(maxRating))
        addGesture()
    }
    
    func addGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        gesture.numberOfTapsRequired = 1
        addGestureRecognizer(gesture)
    }
    
    @objc func handleTap(gesture : UITapGestureRecognizer) {
        let point = gesture.location(in: self)
        handleTouchAtLocation(touchLocation: point, shouldReturnRating: true)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let frameWidth = frame.width
        let topEquation = frameWidth - (sideMargin * 2) - (midMargin * (maxRating - 1))
        let desiredImageWidth = topEquation/CGFloat(imageViews.count)
        let imageWidth = max(minImageSize.width, desiredImageWidth)
        //        let imageHeight = max(minImageSize.height, frame.height)
        
        for i in 0..<imageViews.count {
            let imageView = imageViews[i]
            imageView.frame = CGRect(x: sideMargin + (CGFloat(i) * (imageWidth + midMargin)), y: 0, width: imageWidth, height: imageWidth)
            imageView.layer.cornerRadius = imageView.frame.width/2
            imageView.clipsToBounds = true
            imageView.layer.masksToBounds = true
        }
    }
    
    func refresh() {
        for i in 0..<imageViews.count {
            let imageView = imageViews[i]
            //            if rating == (i + 1) {
            //                imageView.backgroundColor = UIColor(red: 240/255, green: 216/255, blue: 93/255, alpha: 1.0)
            //            }else {
            //                imageView.backgroundColor = UIColor.lightGray
            //            }
            if rating >= (i + 1) {
                imageView.image = selectedImage
            }else {
                imageView.image = unselectedImage
            }
        }
    }
    
    func getImageFor(position : Int) -> UIImage? {
        //        switch position {
        //        case 0:
        //            return terribleImage
        //        case 1:
        //            return badImage
        //        case 2:
        //            return okImage
        //        case 3:
        //            return goodImage
        //        case 4:
        //            return ExcellentImage
        //        default:
        //            return terribleImage
        //        }
        return unselectedImage
    }
    
    @objc func setRating(rating : Int) {
        self.rating = rating
        refresh()
    }
    
    func setMaxRating(maxRating : Int) {
        self.maxRating = CGFloat(maxRating)
        
        for imgView in imageViews {
            imgView.removeFromSuperview()
        }
        imageViews.removeAll()
        
        for i in 0..<maxRating {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.image = getImageFor(position: i)
            imageViews.append(imageView)
            addSubview(imageView)
        }
        
        setNeedsLayout()
        refresh()
    }
    
    func handleTouchAtLocation(touchLocation : CGPoint, shouldReturnRating : Bool) {
        if !editable {
            return
        }
        var newRating = 0
        for i in (0..<imageViews.count).reversed() {
            let imageView = imageViews[i]
            if touchLocation.x > imageView.frame.origin.x {
                newRating = i + 1
                break
            }else if (i == 0 && touchLocation.x < imageView.frame.origin.x) {
                newRating = 1
                break
            }
        }
        rating = newRating
        refresh()
        if shouldReturnRating {
            delegate?.rateViewDidChangeRating(rateView: self, rating: rating)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch?.location(in: self)
        handleTouchAtLocation(touchLocation: touchLocation!, shouldReturnRating: false)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch?.location(in: self)
        handleTouchAtLocation(touchLocation: touchLocation!, shouldReturnRating: false)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.rateViewDidChangeRating(rateView: self, rating: rating)
    }
    
}

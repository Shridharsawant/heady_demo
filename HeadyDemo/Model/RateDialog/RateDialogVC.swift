//
//  RateDialogVC.swift
//  UTS-iPhone
//
//  Created by Shridhar Sawant on 14/03/18.
//  Copyright © 2018 sanofi.in. All rights reserved.
//

import UIKit
import KGModal

class RateDialogVC: UIViewController, DriverRateViewDelegate {
    

    @IBOutlet weak var rateView: DriverRateView!
    var tripID = ""
    var rideID : Double = 0
    var finalRating = 1
    var delegate : TrackVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rateView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onDismissButtonPress(_ sender: Any) {
        KGModal.sharedInstance().hide(animated: true)
    }
    
    @IBAction func onSendButtonPress(_ sender: Any) {
        KGModal.sharedInstance().hide {
            if self.delegate != nil {
                self.delegate!.didSelectRating(rating: self.finalRating)
            }
        }
    }
    
    // MARK: - RATEVIEW DELEGATES
    
    func rateViewDidChangeRating(rateView: DriverRateView, rating: Int) {
        finalRating = rating
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

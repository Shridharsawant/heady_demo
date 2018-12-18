//
//  ProductTVC.swift
//  HeadyDemo
//
//  Created by Shridhar Sawant on 18/12/18.
//  Copyright © 2018 Shridhar Sawant. All rights reserved.
//

import UIKit

class ProductTVC: UITableViewCell {

    @IBOutlet weak var variantLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var viewLabel: UILabel!
    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

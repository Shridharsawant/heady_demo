//
//  ProductListVC.swift
//  HeadyDemo
//
//  Created by Shridhar Sawant on 17/12/18.
//  Copyright © 2018 Shridhar Sawant. All rights reserved.
//

import UIKit

class ProductListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var productsArray = [STProduct]()

    @IBOutlet weak var productsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - TABLEVIEW METHODS
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PRODUCT_TVC_IDENTIFIER, for: indexPath) as! ProductTVC
        
        let product = productsArray[indexPath.row]
        cell.titleLabel.text = product.name
        
        if product.variants.count > 0 {
            let variant = product.variants[0]
            cell.variantLabel.text = variant.color
            cell.priceLabel.text = "₹" + String(variant.price)
        } else {
            cell.variantLabel.text = ""
            cell.priceLabel.text = ""
        }
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

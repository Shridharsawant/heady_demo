//
//  ProductListVC.swift
//  HeadyDemo
//
//  Created by Shridhar Sawant on 17/12/18.
//  Copyright © 2018 Shridhar Sawant. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class ProductListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var productsArray = [STProduct]()

    @IBOutlet weak var productsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addSortButton()
    }
    
    func addSortButton() {
        let sortButton = UIBarButtonItem(image: UIImage(named: "sort_icon"),
                                         style: .done,
                                         target: self,
                                         action: #selector(sortAction))
        navigationItem.rightBarButtonItem = sortButton
    }
    
    @objc func sortAction() {
        let options = ["Most Ordered", "Most Viewed", "Most Shared"]
        let picker = ActionSheetStringPicker(title: "Select parameter",
                                             rows: options,
                                             initialSelection: 0,
                                             doneBlock: { (picker, position, data) in
                                                self.sortArray(key: options[position])
        },
                                             cancel: { (picker) in
                                                
        },
                                             origin: view)
        picker?.show()
    }
    
    func sortArray(key : String) {
        productsArray = productsArray.sorted(by: { (a, b) -> Bool in
            if key == "Most Ordered" {
                return a.order_count > b.order_count
            } else if key == "Most Viewed" {
                return a.view_count > b.view_count
            } else if key == "Most Shared" {
                return a.shares > b.shares
            }
            return true
        })
        productsTableView.reloadData()
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
        cell.viewLabel.text = String(product.view_count.clean) + " views"
        cell.shareLabel.text = String(product.shares.clean) + " shares"
        cell.orderLabel.text = "(" + String(product.order_count.clean) + " orders)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func openProductVC(product : STProduct)  {
        if let vc = storyboard?.instantiateViewController(withIdentifier: PRODUCT_VC_IDENTIFIER) as? ProductVC {
            vc.product = product
            navigationController?.pushViewController(vc, animated: true)
        }
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

//
//  ProductVC.swift
//  HeadyDemo
//
//  Created by Shridhar Sawant on 20/12/18.
//  Copyright © 2018 Shridhar Sawant. All rights reserved.
//

import UIKit

class ProductVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var product = STProduct()

    @IBOutlet weak var variantLabel: UILabel!
    @IBOutlet weak var variantCollectionView: UICollectionView!
    @IBOutlet weak var ordersLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    
    var selectedRow : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUI()
    }
    
    func setUI() {
        productNameLabel.text = product.name
        ordersLabel.text = "(" + String(product.order_count.clean) + " orders)"
        if !product.variants.isEmpty {
            let variant = product.variants[0]
            variantLabel.text = variant.color
            priceLabel.text = "₹" + String(variant.price)
        }
    }

    // MARK: - COLELCTIONVIEW METHODS
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return product.variants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VARIANT_CVC_IDENTIFIER, for: indexPath) as! VariantCVC
        let data = product.variants[indexPath.row]
        cell.sizeLabel.text = data.size + " inches"
        cell.colorLabel.text = data.color
        if selectedRow != nil {
            if indexPath.row == selectedRow {
                cell.layer.borderColor = UIColor.red.cgColor
            }else {
                cell.layer.borderColor = UIColor.lightGray.cgColor
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //collectionView.deselectItem(at: indexPath, animated: true)
        let data = product.variants[indexPath.row]
        priceLabel.text = String(data.price)
        variantLabel.text = data.color
        selectedRow = indexPath.row
        collectionView.reloadData()
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

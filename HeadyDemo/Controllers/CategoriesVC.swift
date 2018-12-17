//
//  CategoriesVC.swift
//  HeadyDemo
//
//  Created by Shridhar Sawant on 17/12/18.
//  Copyright © 2018 Shridhar Sawant. All rights reserved.
//

import UIKit

class CategoriesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        callService()
    }
    
    func callService() {
        getProducts()
    }
    
    // MARK: - TABLEVIEW METHODS
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CATEGORY_PARENT_TVC, for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - WEB SERVICE METHODS
    
    func getProducts() {
        let service = ServiceModel()
        service.getProducts(url: PRODUCTS_URL,
                            controller: self) { (data, response, error) in
                                self.parseProductsResponse(data: data, response: response, error: error)
        }
    }
    
    func parseProductsResponse(data : Any?, response : URLResponse?, error : Error?) {
        if let dictionary = data as? [String : Any] {
            
            if let categories = dictionary[WS_CATEGORIES] as? [[String : Any]] {
                var categoriesArray = [STCategory]()
                for category in categories {
                    var categoryModel = STCategory()
                    
                    let id = categories[WS_ID] as? Int ?? 0
                    let name = categories[WS_NAME] as? String ?? ""
                    if let products = category[WS_PRODUCTS] as? [[String : Any]] {
                        var productsArray = [STProduct]()
                        for product in products {
                            
                            var productModel = STProduct()
                            
                            let id = product[WS_ID] as? Int ?? 0
                            let name = product[WS_NAME] as? String ?? ""
                            let date_added = product[WS_DATE_ADDED] as? String ?? ""
                            if let variants = product[WS_VARIANTS] as? [[String : Any]] {
                                var variantArray = [STVariant]()
                                for variant in variants {
                                    let id = variant[WS_ID] as? Int ?? 0
                                    let color = variant[WS_COLOR] as? String ?? ""
                                    let size = variant[WS_SIZE] as? Int ?? 0
                                    let price = variant[WS_PRICE] as? Double ?? 0
                                    
                                    var variantModel = STVariant()
                                    variantModel.id = id
                                    variantModel.color = color
                                    variantModel.price = price
                                    variantModel.size = size
                                    variantArray.append(variantModel)
                                }
                                productModel.variants = variantArray
                            }
                            
                            if let tax = variant[WS_TAX] as? [String : Any] {
                                let name = tax[WS_NAME] as? String ?? ""
                                let value = tax[WS_VALUE] as? Double ?? 0
                                
                                var taxModel = STTax()
                                taxModel.name = name
                                taxModel.value = value
                                productModel.tax = taxmodel
                            }
                            
                            productModel.id = id
                            productModel.name = name
                            productModel.date_added = date_added
                            productsArray.append(productModel)
                        }
                        categoryModel.products = productsArray
                    }
                    let child_categories = category[WS_CHILD_CATEGORIES] as? [Int] ?? []
                    
                    categoryModel.id = id
                    categoryModel.name = name
                    categoryModel.child_categories = child_categories
                    categoriesArray.append(categoryModel)
                }
            }
            
            if let rankings = dictionary[WS_RANKINGS] as? [[String : Any]] {
                
            }
            
        } else {
            
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

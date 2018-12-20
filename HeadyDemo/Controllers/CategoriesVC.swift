//
//  CategoriesVC.swift
//  HeadyDemo
//
//  Created by Shridhar Sawant on 17/12/18.
//  Copyright © 2018 Shridhar Sawant. All rights reserved.
//

import UIKit

class CategoriesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var categoriesTableView: UITableView!
    var categoriesArray = [STCategory]()
    var finalArray = [STCategory]()
    
    let CHILD_FONT_SIZE : CGFloat = 15.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //callService()
        checkIfDataExistsLocally()
    }
    
    func checkIfDataExistsLocally() {
        categoriesArray.removeAll()
        if let categoriesArr = DBManager.getSharedInstance()?.getCategories() {
            if categoriesArr.isEmpty {
                getProducts()
                return
            }
            for item in categoriesArr {
                if let category = item as? [String : Any] {
                    var categoryType = STCategory()
                    let categoryIdStr = category["categoryId"] as? String ?? ""
                    categoryType.id = Int(categoryIdStr) ?? 0
                    categoryType.name = category["name"] as? String ?? ""
                    if let childCategoriesString = category["child_categories"] as? String {
                        if childCategoriesString.trimmingCharacters(in: .whitespaces) != "" {
                            let childCategoriesStrArr = childCategoriesString.components(separatedBy: ",")
                            if childCategoriesStrArr.count > 0 {
                                let childCategoriesArr = childCategoriesStrArr.map { Int($0)!}
                                categoryType.child_categories = childCategoriesArr
                            }else {
                                categoryType.child_categories = []
                            }
                        }
                    }
                    categoryType.is_expanded = false
                    if let prodArr = DBManager.getSharedInstance()?.getProducts(categoryIdStr) {
                        var productsArr = [STProduct]()
                        if prodArr.count > 0 {
                            for item in prodArr {
                                if let product = item as? [String : Any] {
                                    var productType = STProduct()
                                    productType.name = product["name"] as? String ?? ""
                                    let productIdStr = product["productId"] as? String ?? ""
                                    productType.id = Int(productIdStr) ?? 0
                                    productType.date_added = product["date_added"] as? String ?? ""
                                    
                                    let viewCountStr = product["view_count"] as? String ?? ""
                                    let order_countStr = product["order_count"] as? String ?? ""
                                    let sharesStr = product["share"] as? String ?? ""
                                    
                                    
                                    productType.view_count = Double(viewCountStr) ?? 0
                                    productType.shares = Double(sharesStr) ?? 0
                                    productType.order_count = Double(order_countStr) ?? 0
                                    
                                    if let taxArr = DBManager.getSharedInstance()?.getTax(productIdStr) {
                                        if taxArr.count > 0 {
                                            for item in taxArr {
                                                if let tax = item as? [String : Any] {
                                                    var taxType = STTax()
                                                    taxType.name = tax["name"] as? String ?? ""
                                                    taxType.value = tax["value"] as? Double ?? 0
                                                    productType.tax = taxType
                                                }
                                            }
                                        }
                                    }
                                    if let varArr = DBManager.getSharedInstance()?.getVariants(productIdStr) {
                                        if varArr.count > 0 {
                                            var variantArray = [STVariant]()
                                            for item in varArr {
                                                if let variant = item as? [String : Any] {
                                                    
                                                    var variantType = STVariant()
                                                    variantType.color = variant["color"] as? String ?? ""
                                                    variantType.size = variant["size"] as? String ?? ""
                                                    let priceStr = variant["price"] as? String ?? ""
                                                    variantType.price = Double(priceStr) ?? 0
                                                    variantType.id = variant["id"] as? Int ?? 0
                                                    variantArray.append(variantType)
                                                }
                                            }
                                            productType.variants = variantArray
                                        }
                                    }
                                    productsArr.append(productType)
                                }
                            }
                        }
                        categoryType.products = productsArr
                    }
                    categoriesArray.append(categoryType)
                }
            }
            parseCategories()
        }
    }
    
    
    // MARK: - FETCH METHODS
    
    func callService() {
        getProducts()
    }
    
    // MARK: - TABLEVIEW METHODS
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return finalArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let category = finalArray[indexPath.row]
        if category.has_parent {
            let cell = tableView.dequeueReusableCell(withIdentifier: CATEGORY_CHILD_TVC, for: indexPath) as! CategoryChildTVC
            if category.is_expanded {
                cell.titleLabel.font = UIFont.boldSystemFont(ofSize: CHILD_FONT_SIZE)
            } else {
                cell.titleLabel.font = UIFont.systemFont(ofSize: CHILD_FONT_SIZE)
            }
            if category.child_categories.count > 0 {
                cell.titleLeadingConstraint.constant = 24
            } else {
                cell.titleLeadingConstraint.constant = 36
            }
            cell.titleLabel.text = category.name
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CATEGORY_PARENT_TVC, for: indexPath) as! CategoryParentTVC
            cell.titleLabel.text = category.name
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var category = finalArray[indexPath.row]
        if category.products.count > 0 {
            //open product list
            openProductListVC(category: category)
        } else if category.child_categories.count > 0 {
            if category.is_expanded {
                var indexArray = [IndexPath]()
                var i = 0
                for _ in category.child_categories {
                    let position = indexPath.row + 1
                    let currentCategory = finalArray[position]
                    finalArray.remove(at: position)
                    indexArray.append(IndexPath(row: (position + i), section: 0))
                    i = i + 1
                    
                    if currentCategory.is_expanded {
                        for _ in currentCategory.child_categories {
                            let position = indexPath.row + 1
                            finalArray.remove(at: position)
                            indexArray.append(IndexPath(row: (position + i), section: 0))
                            i = i + 1
                        }
                    }
                }
                tableView.deleteRows(at: indexArray, with: .automatic)
            } else {
                //expand childs
                var i = 1
                var indexArray = [IndexPath]()
                for childCategoryId in category.child_categories {
                    let position = childCategoryId - 1
                    let childCategory = categoriesArray[position]
                    finalArray.insert(childCategory, at: indexPath.row + i)
                    indexArray.append(IndexPath(row: indexPath.row + i, section: 0))
                    i = i + 1
                }
                tableView.insertRows(at: indexArray, with: .automatic)
            }
            category.is_expanded = !category.is_expanded
            finalArray[indexPath.row] = category
            tableView.reloadRows(at: [indexPath], with: .none)
        }
        //tableView.reloadData()
    }
    
    // MARK: - Navigation
    
    func openProductListVC(category : STCategory) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: PRODUCT_LIST_VC_IDENTIFIER) as? ProductListVC {
            vc.productsArray = category.products
            vc.title = category.name
            navigationController?.pushViewController(vc, animated: true)
        }
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
                categoriesArray.removeAll()
                for category in categories {
                    var categoryModel = STCategory()
                    
                    let category_id = category[WS_ID] as? Int ?? 0
                    let name = category[WS_NAME] as? String ?? ""
                    if let products = category[WS_PRODUCTS] as? [[String : Any]] {
                        var productsArray = [STProduct]()
                        for product in products {
                            
                            var productModel = STProduct()
                            
                            let productId = product[WS_ID] as? Int ?? 0
                            let name = product[WS_NAME] as? String ?? ""
                            let date_added = product[WS_DATE_ADDED] as? String ?? ""
                            if let variants = product[WS_VARIANTS] as? [[String : Any]] {
                                var variantArray = [STVariant]()
                                for variant in variants {
                                    let id = variant[WS_ID] as? Int ?? 0
                                    let color = variant[WS_COLOR] as? String ?? ""
                                    let size = variant[WS_SIZE] as? String ?? ""
                                    let price = variant[WS_PRICE] as? Double ?? 0
                                    
                                    var variantModel = STVariant()
                                    variantModel.id = id
                                    variantModel.color = color
                                    variantModel.price = price
                                    variantModel.size = size
                                    variantArray.append(variantModel)
                                    DBManager.getSharedInstance()?.insertVariants(Int32(productId),
                                                                                  variantId: Int32(id),
                                                                                  color: color,
                                                                                  size: size,
                                                                                  price: String(price))
                                }
                                productModel.variants = variantArray
                            }
                            
                            if let tax = product[WS_TAX] as? [String : Any] {
                                let name = tax[WS_NAME] as? String ?? ""
                                let value = tax[WS_VALUE] as? Double ?? 0
                                
                                var taxModel = STTax()
                                taxModel.name = name
                                taxModel.value = value
                                productModel.tax = taxModel
                                DBManager.getSharedInstance()?.insertTax(Int32(productId),
                                                                         name: name,
                                                                         value: String(value))
                            }
                            
                            productModel.id = productId
                            productModel.name = name
                            productModel.date_added = date_added
                            
                            DBManager.getSharedInstance()?.insertProducts(Int32(category_id),
                                                                          productId: Int32(productId),
                                                                          name: name,
                                                                          dateAdded: date_added)
                            productsArray.append(productModel)
                        }
                        categoryModel.products = productsArray
                    }
                    let child_categories = category[WS_CHILD_CATEGORIES] as? [Int] ?? []
                    
                    categoryModel.id = category_id
                    categoryModel.name = name
                    categoryModel.child_categories = child_categories
                    
                    let stringArray = child_categories.map { String($0) }
                    let strArr = stringArray.joined(separator: ",")
                    
                    DBManager.getSharedInstance()?.insertCategory(Int32(category_id),
                                                                  name: name,
                                                                  child_CATEGORIES: strArr)
                    
                    categoriesArray.append(categoryModel)
                }
                //parseCategories()
            }
            
            if let rankings = dictionary[WS_RANKINGS] as? [[String : Any]] {
                for rankingType in rankings {
                    if let ranking = rankingType[WS_RANKING] as? String {
                        var rankingKey = ""
                        if ranking == "Most Viewed Products" {
                            rankingKey = WS_VIEW_COUNT
                        } else if ranking == "Most OrdeRed Products" {
                            rankingKey = WS_ORDER_COUNT
                        } else if ranking == "Most ShaRed Products" {
                            rankingKey = WS_SHARES
                        }
                        
                        if let products = rankingType[WS_PRODUCTS] as? [[String : Any]] {
                            for product in products {
                                let id = product[WS_ID] as? Int ?? 0
                                let rank = product[rankingKey] as? Double ?? 0
                                DBManager.getSharedInstance()?.updateRankforProduct(Int32(id),
                                                                                    rankKey: rankingKey,
                                                                                    value: String(rank))
                            }
                        }
                    }
                }
            }
            
        } else {
            
        }
        checkIfDataExistsLocally()
    }
    
    func parseCategories() {
        categoriesArray = categoriesArray.sorted(by: { (categoryA, categoryB) -> Bool in
            return categoryA.id < categoryB.id
        })
        for i in 0..<categoriesArray.count {
            let category = categoriesArray[i]
            if category.child_categories.count > 0 {
                for childCategoryId in category.child_categories {
                    let position = childCategoryId - 1
                    var childCategory = categoriesArray[position]
                    childCategory.has_parent = true
                    categoriesArray[position] = childCategory
                }
            }
        }
        finalArray = categoriesArray.filter { (category) -> Bool in
            return !category.has_parent
        }
        categoriesTableView.reloadData()
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

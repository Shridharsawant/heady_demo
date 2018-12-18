//
//  Structures.swift
//  UTSupervisor
//
//  Created by Shridhar Sawant on 25/07/18.
//  Copyright © 2018 Plextiech. All rights reserved.
//

import Foundation

struct STCategory {
    var id = 0
    var name = ""
    var products = [STProduct]()
    var child_categories = [Int]()
    var has_parent = false
    var is_expanded = false
}

struct STProduct {
    var id = 0
    var name = ""
    var date_added = ""
    var variants = [STVariant]()
    var tax = STTax()
}

struct STVariant {
    var id = 0
    var color = ""
    var size = ""
    var price : Double = 0
}

struct STTax {
    var name = ""
    var value : Double = 0
}

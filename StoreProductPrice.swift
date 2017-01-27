//
//  ProductPrice.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 2/23/16.
//  Copyright © 2016 Bondzu. All rights reserved.
//

import UIKit

/**
 This class gives all the information about the item price. 
 This item **must** be created by StoreProduct.
 
 This object represents the price for a product. This class is also inmutable
 
 SeeAlso: `StoreProduct`
 */
open class StoreProductPrice: NSObject {
    
    /// The price of the product in MXN
    let price : Double
    
    /// The parse product id
    let productID : String
    
    /// The minimum required priority for this price to be applied
    let minPriority : Int
    
    /// The price parse object id
    let priceID: String
    
    /**
     Default constructor for the class
     
     - parameter object: The parse object that represents a price
     */
    init(object : PFObject){
        self.price = object[TableStorePriceColumnNames.Price.rawValue] as! Double
        self.productID = (object[TableStorePriceColumnNames.Product.rawValue] as! PFObject).objectId!
        self.minPriority = object[TableStorePriceColumnNames.Prority.rawValue] as! Int
        self.priceID = object.objectId!
    }

    

}

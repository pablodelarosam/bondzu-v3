//
//  StoreProduct.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 2/23/16.
//  Copyright © 2016 Bondzu. All rights reserved.
//

import UIKit

/**
 The protocol conains methods for calling the delegate about a store product
 */
@objc public protocol StoreProductProtocol{
    func storeProductDidFinishLoading(_ product : StoreProduct)
    func storeProductDidFailLoading(_ product : StoreProduct)
}

/**
 This class represents a Store product from the database. This method will call a delegate when the object has been fully initialized and requires a PFObject for initializing.
 */
open class StoreProduct: NSObject {
 
    /// A variable telling if the class is loading its image or not. If loadedImage is true this will allways be false.
    fileprivate var loading = false
    
    /// A variable that tells if the image of the product has been loaded or not.
    fileprivate var hasLoadedImage = false
    
    
    /// The image of the product
    open var image : UIImage?
    
    /// The description of the product
    open var productDescription : String
    
    
    /// A variable that says if the product is purchasable or not.
    open var purchasable : Bool
    
    /// The original parse object that may be used for updates or for reference in other classes
    open var originalObject : PFObject
    
    /// The delegate that is going to be called when the image is loaded
    open weak var delegate : StoreProductProtocol?
    
    /**
     This is the default constructor of the class. This should be called to use a Store Product
     
     - parameter object: The parse object containing the information of the product
     - parameter delegate: Optionally, the delegate that should be called when the image loads.
     - parameter loadImage: **Only important if delegate is nil. Otherwise ignored** This variable tells explicitly the class that it should load the image despite that there is no delegate. Default value is false
     */
    public init(object : PFObject, delegate : StoreProductProtocol?, loadImage : Bool = false){
        
        self.productDescription = object[TableStoreProductColumnNames.Description.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! String
        self.purchasable = object[TableStoreProductColumnNames.Purchasable.rawValue] as! Bool
        self.originalObject = object
        self.delegate = delegate
        super.init()
        if delegate != nil || loadImage{
            self.loadImage()
        }
    }
    
    /**
     This method should be called to tell the class that it should load the image. 
     The return value will vary according to the class state:
     
     - false: If the class is already loading
     - false: If the image has already been loaded
     - true: If the loading process has started
     
     - returns: A boolean telling if the class will attemp to load the image or not.
     
     */
    func loadImage()->Bool{
        
        guard !self.loading && !self.hasLoadedImage else{
            return false
        }
        
        self.loading = true
        let file = self.originalObject[TableStoreProductColumnNames.Image.rawValue] as! PFFile
        file.getDataInBackground(block: {
            [weak self]
            (data, error) -> Void in
            
            guard let s = self else{
                return
            }
            
            if error != nil{
                let img = UIImage(data: data!)
                if img != nil{
                    s.image = img
                    s.loading = false
                    s.hasLoadedImage = true
                    s.delegate?.storeProductDidFinishLoading(s)
                }
                else{
                    s.loading = false
                    s.delegate?.storeProductDidFailLoading(s)
                }
            }
            else{
                s.delegate?.storeProductDidFailLoading(s)
            }
        })
        return true
    }
    
    
    /**
     This function queries for the price that applies to a certain type. This is the only provided way to create the prices for the products.
     
     - parameter priority: The price for the requested user type
     - parameter callback: The block that is going to be called when the price is ready. The paramaters of the block are the following:
        - StoreProduct: The requested product.
        - Int: The requested priority.
        - StoreProductPrice: The generated price. If there is no price for a certain user, a nl will be passed.
     
     - note: This price won't be updated if the user promotes its category. Thats why the sent parameters are being sended back.
     */
    func priceForPriority(_ priority : Int, callback : @escaping (StoreProduct, Int, StoreProductPrice?)->()){
        let query = generateQueryForPrice(false)
        query.whereKey(TableStorePriceColumnNames.Product.rawValue, equalTo: self.originalObject.objectId!)
        query.whereKey(TableStorePriceColumnNames.Prority.rawValue, lessThanOrEqualTo: priority)
        query.order(byDescending: TableStorePriceColumnNames.Prority.rawValue)
        query.getFirstObjectInBackground {
            (fetchedPricePFObject, error) -> Void in
            
            guard error == nil , let object = fetchedPricePFObject else{
                callback(self, priority, nil)
                return
            }
            
            let price = StoreProductPrice(object: object)
            callback(self, priority, price)
        }
    }
    
    /**
     This function should be called when `priceForPriority` returned a nil price. 
     
     - parameter callback: The callback that is going to be called when the information is ready. The parameters of the callback are the following:
     **StoreProduct**: The product that is sending the information
     **UserType**: The required UserType for purchasing an item. Will be nil if the item is not purchasable or if there is no purchasable type of user with the required permission (Database inconsistency)
     */
    func requiredTypeForPurchasingItem(_ callback : @escaping (StoreProduct , UserType?)->()){
        let query = generateQueryForPrice(true)
        query.getFirstObjectInBackground {

            (userType, error) -> Void in
            guard error == nil , let object = userType else{
                callback(self, nil)
                return
            }
            
            let userType = UserType(object: object)
            callback(self, userType)
        }

    }
    
    /**
     This method generates the query for the price. All methods that want to query price should call this method to follow the design principle DRY
     
     - parameter orderAscending: Tells if the query should be order ascending (*true*) or descending (*false*)
     
     - returns: A query configured with the correct ordering and the product already set.

     */
    fileprivate func generateQueryForPrice(_ orderAscending : Bool) -> PFQuery<PFObject>{
        let query = PFQuery(className: TableNames.StoreProductPrice.rawValue)
        query.whereKey(TableStorePriceColumnNames.Product.rawValue, equalTo: self.originalObject.objectId!)
        if orderAscending{
            query.order(byDescending: TableStorePriceColumnNames.Prority.rawValue)
        }
        else{
            query.order(byAscending: TableStorePriceColumnNames.Prority.rawValue)
        }
        
        return query
    }
    
    
}

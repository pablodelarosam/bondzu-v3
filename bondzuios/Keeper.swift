//
//  Keeper.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 11/9/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//

import UIKit
import Parse


class Keeper {
    
    /**
     This is the default initializer for a keeper.
     
     - parameter object: The PFObject containing the keeper.
     - parameter imageLoaderObserver: A observer that tells its delegate when the image have loaded (or failed). The observer parameters are described below.
        - Usuario: The parent object that has finished (or failed) loading.
        - Bool: Its value tells its delegate if the image could be loaded or not.
     
     */
    class func getKeeper(keeperObject : PFObject, imageLoaderObserver: ((Usuario?, Bool)->(Void))?){

        
       (keeperObject[TableKeeperColumnNames.User.rawValue] as! PFObject).fetchInBackgroundWithBlock {
            (object, error) -> Void in
            if error == nil{
                _ = Usuario(object: object!, imageLoaderObserver: imageLoaderObserver)
            }
            else{
                dispatch_async(dispatch_get_main_queue()){
                    imageLoaderObserver?(nil, false)
                }
            }
        }
        
    }

}

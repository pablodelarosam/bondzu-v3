//
//  UserType.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 1/11/16.
//  Copyright © 2016 Bondzu. All rights reserved.
//

import UIKit

class UserType: NSObject {
    
    let color : UIColor
    let name : String
    let priority : Int
    let cost : Double
    let sellable : Bool
    
    
    init(object : PFObject){
        self.color = UIColor(red: object[TableUserTypeColumnNames.RedChanel.rawValue] as! CGFloat / 255, green: object[TableUserTypeColumnNames.GreenChanel.rawValue] as! CGFloat / 255, blue: object[TableUserTypeColumnNames.BlueChanel.rawValue] as! CGFloat / 255, alpha: 1)
        self.name = object[TableUserTypeColumnNames.UserTypeName.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "") ] as! String
        self.priority = object[TableUserTypeColumnNames.Priority.rawValue] as! Int
        self.cost = object[TableUserTypeColumnNames.Cost.rawValue] as! Double
        self.sellable = object[TableUserTypeColumnNames.Purchasable.rawValue] as! Bool
    }
    
}

//
//  Animal.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 12/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//

import Foundation
import Parse

class Animal: PFObject, PFSubclassing
{
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    class func parseClassName() -> String {
        return "AnimalV2"
    }
    
    var id: String? {
        get {
            return self["objectId"] as? String
        }
        set {
            self["objectId"] = newValue
        }
    }
    
    @NSManaged var name: String!
    @NSManaged var url: String!
    @NSManaged var type: NSNumber!    
    
}
//
//  Animal.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 12/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//  Archivo localizado

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
    
    //TODO Actualizar para AnimalV2
    class func parseClassName() -> String {
        return TableNames.Animal_table.rawValue
    }
    
    var id: String? {
        get {
            return self[TableAnimalColumnNames.ID.rawValue] as? String
        }
        set {
            self[TableAnimalColumnNames.ID.rawValue] = newValue
        }
    }
    
    @NSManaged var name: String!
    @NSManaged var url: String!
    @NSManaged var type: NSNumber!    
    
}
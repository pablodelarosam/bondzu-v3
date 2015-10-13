//
//  AnimalV2.swift
//  bondzuios
//
//  Created by Mariano on 03/09/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//  Archivo Localizado

import Foundation

class AnimalV2 : Equatable
{
    var image =  UIImage();
    var name: String!;
    var specie: String!;
    var objectId: String!;
    
}


func ==(lhs: AnimalV2, rhs: AnimalV2) -> Bool{
    return lhs.objectId == rhs.objectId
}
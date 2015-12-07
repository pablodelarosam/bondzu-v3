//
//  Camera.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 12/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//  Archivo Localizado

import Foundation
import Parse
class Camera
{
    var objectId: String!;
    var descripcion: String!;
    var animalId: String!;
    var animalName: String!;
    var funcionando: Bool!;
    var url: NSURL?;
    
    @available(*, deprecated=9.0, message="Please use the new object constructor!")
    init(_obj_id: String!, _description: String!, _animalId: String!, _type: Int!, _animalName: String!, _funcionando: Bool!, _url: String?)
    {
        self.objectId = _obj_id;
        self.descripcion = _description;
        self.animalId = _animalId;
        self.animalName = _animalName;
        self.funcionando = _funcionando;
        if let url = _url as String!
        {
            self.url = NSURL(string: url);
        }else{
            self.url = nil
        }
    }
    
    
    init(object : PFObject){
        self.objectId = object.objectId!
        self.descripcion = object[TableCameraColumnNames.Description.rawValue] as! String
        self.animalId = (object[TableCameraColumnNames.Animal.rawValue] as! PFObject).objectId!
        self.animalName = object[TableCameraColumnNames.AnimalName.rawValue] as! String
        self.funcionando = object[TableCameraColumnNames.Working.rawValue] as! Bool
        self.url = NSURL(string: object[TableCameraColumnNames.PlayBackURL.rawValue] as! String)
    }
    
}
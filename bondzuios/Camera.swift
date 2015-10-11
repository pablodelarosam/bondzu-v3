//
//  Camera.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 12/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//  Archivo Localizado

import Foundation

class Camera
{
    var objectId: String!;
    var descripcion: String!;
    var animalId: String!;
    var type: Int!;
    var animalName: String!;
    var funcionando: Bool!;
    var url: NSURL?;
    
    init(_obj_id: String!, _description: String!, _animalId: String!, _type: Int!, _animalName: String!, _funcionando: Bool!, _url: String?)
    {
        self.objectId = _obj_id;
        self.descripcion = _description;
        self.animalId = _animalId;
        self.type = _type;
        self.animalName = _animalName;
        self.funcionando = _funcionando;
        if let url = _url as String!
        {
            self.url = NSURL(string: url);
        }else{
            self.url = nil
        }
    }
}
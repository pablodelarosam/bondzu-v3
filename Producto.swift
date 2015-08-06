//
//  Producto.swift
//  Bondzu
//
//  Created by Luis Mariano Arobes on 06/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//

import Foundation
import UIKit

class Regalo
{
    var objectId: String;
    var nombre: String;
    var photo: UIImage;
    var categoria: String;
    var animalId: String;
    var descripcion: String;
    var precio1: Double;
    var precio2: Double;
    var precio3: Double;
    var disponible: Bool;
    var info: String;
    var infoAmount: String;
    
    init(_id: String, _nombre: String, pic: UIImage, _categoria: String, _animalId: String, _descripcion: String, _precio1: Double, _precio2: Double, _precio3: Double, _disponible: Bool, _info: String, _infoAmount: String)    {
        self.objectId = _id;
        self.nombre = _nombre;
        self.photo = pic;
        self.categoria = _categoria;
        self.animalId = _animalId;
        self.descripcion = _descripcion;
        self.precio1 = _precio1;
        self.precio2 = _precio2;
        self.precio3 = _precio3;
        self.disponible = _disponible;
        self.info = _info;
        self.infoAmount = _infoAmount;
    }
}
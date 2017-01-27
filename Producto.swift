//
//  Producto.swift
//  Bondzu
//
//  Created by Luis Mariano Arobes on 06/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//  Archivo Localizado

import Foundation
import UIKit

protocol ProductoLoadingProtocol{
    func productoDidFinishLoading(_ product : Producto)
    func productoDidFailedLoading(_ product : Producto)
}

class Producto{
    
    var objectId: String;
    var nombre: String;
    var photo = UIImage()
    var categoria: String;
    var animalId: String;
    var descripcion: String;
    var precio1: Double;
    var precio2: Double;
    var precio3: Double;
    var disponible: Bool;
    var info: String;
    var infoAmount: String;
    var originalObject : PFObject!
    
    @available(*,deprecated: 9.0, message: "Deprecated. Please use the new object constructor")
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
    
    init?(object : PFObject, delegate : ProductoLoadingProtocol?, loadImage : Bool = false){
        objectId = object.objectId!
        originalObject = object
        nombre = object[TableProductColumnNames.Name.rawValue +  NSLocalizedString(LOCALIZED_STRING, comment: "")] as! String
        categoria = object[TableProductColumnNames.Category.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! String
        descripcion = object[TableProductColumnNames.Description.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! String
        precio1 = object[TableProductColumnNames.Price1.rawValue] as! Double
        precio2 = object[TableProductColumnNames.Price2.rawValue] as! Double
        precio3 = object[TableProductColumnNames.Price3.rawValue] as! Double
        disponible = object[TableProductColumnNames.Available.rawValue] as! Bool
        info = object[TableProductColumnNames.Information.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! String
        infoAmount = object[TableProductColumnNames.InformationUsage.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! String
        
        if let oid = object[TableProductColumnNames.AnimalID.rawValue] as? PFObject{
            
            guard oid.objectId != nil else{
                animalId = ""
                delegate?.productoDidFailedLoading(self)
                return nil
            }
            
            animalId = oid.objectId!
        }
        else{
            animalId = ""
            delegate?.productoDidFailedLoading(self)
            return nil
        }
        
        if(loadImage || delegate != nil){
            Constantes.get_bondzu_queue().async{
                do{
                    let imageFile = object[TableProductColumnNames.Picture.rawValue] as! PFFile
                    let data = try imageFile.getData()
                    let image = UIImage(data: data)
                    
                    if image == nil{
                        throw Errors.genericError
                    }
                    
                    self.photo = image!
                    
                    DispatchQueue.main.async(){
                        delegate?.productoDidFinishLoading(self)
                    }
                    
                }
                catch{
                    DispatchQueue.main.async(){
                        delegate?.productoDidFailedLoading(self)
                    } //Block of delegate
                } //Catch errors
            } //Dispatch async
        } //Check if image should be downloaded
    }
}

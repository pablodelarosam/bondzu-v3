//
//  AnimalV2.swift
//  bondzuios
//
//  Created by Mariano on 03/09/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//  Archivo Localizado

/*
    Afectado #25

    Keeper debería ser un modelo. no un objeto
*/

import Foundation
import Parse

protocol AnimalV2LoadingProtocol{
    func animalDidFinishLoading(animal : AnimalV2)
    func animalDidFailLoading(animal : AnimalV2)
}

class AnimalV2 : Equatable
{
    var image :  UIImage?
    var name: String
    var specie: String
    var objectId: String
    var adopters : Int
    var characteristics : [String : String]
    var about : String
    var originalObject : PFObject!
    var keepers : [PFObject]?
    
    
    /**
     Instanciates a new AnimalV2 object
     
     - parameter object: The PFObject to parse.
     - parameter delegate: The delegate to notify when the image is ready.
     - parameter loadImage: This parameter will be only taken in mind if the delegate is nil. It tells the wether the associated image is loaded or notociated image. The default value is false
     
    */
    init(object : PFObject, delegate : AnimalV2LoadingProtocol?, loadImage : Bool = false){
        self.objectId = object.objectId!
        self.name = object[TableAnimalColumnNames.Name.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! String
        self.adopters = (object[TableAnimalColumnNames.Adopters.rawValue] as! NSNumber).integerValue
        self.specie = object[TableAnimalColumnNames.Species.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! String
        self.characteristics = object[TableAnimalColumnNames.Characteristics.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! [String:String]
        self.about = object[TableAnimalColumnNames.About.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! String
        self.image = UIImage()
        self.originalObject = object
        
        self.keepers = object[TableAnimalColumnNames.Keepers.rawValue] as? [PFObject]
        
        if delegate != nil || loadImage{
            
            (object[TableAnimalColumnNames.Photo.rawValue] as! PFFile).getDataInBackgroundWithBlock(){
                data , error in
                guard error == nil else{
                    print(error)
                    delegate?.animalDidFailLoading(self)
                    return
                }
                
                guard let imageData = data else{
                    print("data is null\n")
                    delegate?.animalDidFailLoading(self)
                    return
                }
                
                self.image = UIImage(data: imageData)
                
                guard self.image != nil else{
                    print("Fallo en conversion")
                    delegate?.animalDidFailLoading(self)
                    return
                }
                
                delegate?.animalDidFinishLoading(self)
            }
        }
    }
    
    @available(*, deprecated=1.0, message="Please use the new object constructor!")
    init(){
        name = ""
        specie = ""
        objectId = ""
        adopters = 0
        characteristics = [:]
        about = ""
    }
    
}


func ==(lhs: AnimalV2, rhs: AnimalV2) -> Bool{
    return lhs.objectId == rhs.objectId
}


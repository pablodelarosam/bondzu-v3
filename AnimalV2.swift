//
//  AnimalV2.swift
//  bondzuios
//
//  Created by Mariano on 03/09/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//  Archivo Localizado


import Foundation
import Parse

protocol AnimalV2LoadingProtocol{
    /**
     Will be called when the animal has loaded its picture. 
     When called the type may not have been loaded yet
     
     - parameter animal: The sending object
     */
    func animalDidFinishLoading(animal : AnimalV2)
    
    /**
     Will be called when the animal has failed loading its picture.
     When called the type may not have been loaded yet
     
     - parameter animal: The sending object
     */
    func animalDidFailLoading(animal : AnimalV2)
    

    /**
     Will be called when the animal has loaded its required priority.
     
     - parameter animal: The sending object
     */
    func animalDidFinishLoadingPermissionType(animal : AnimalV2)
    
    /**
     Will be called when the animal has failed loading its required priority.
     
     - parameter animal: The sending object
     */
    func animalDidFailedLoadingPermissionType(animal : AnimalV2)
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
    var animalDescription : String
    
    var requiredPermission : UserType?
    var hasLoadedPermission = false
    
    /**
     Instanciates a new AnimalV2 object
     
     - parameter object: The PFObject to parse.
     - parameter delegate: The delegate to notify when the image is ready.
     - parameter loadImage: This parameter will be only taken in mind if the delegate is nil. It tells the wether the associated image is loaded or notociated image. The default value is false
     
    */
    init(object : PFObject, delegate : AnimalV2LoadingProtocol?, loadImage : Bool = false){
        self.originalObject = object
        self.objectId = object.objectId!
        self.name = object[TableAnimalColumnNames.Name.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! String
        self.adopters = (object[TableAnimalColumnNames.Adopters.rawValue] as! NSNumber).integerValue
        self.specie = object[TableAnimalColumnNames.Species.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! String
        self.characteristics = object[TableAnimalColumnNames.Characteristics.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! [String:String]
        self.about = object[TableAnimalColumnNames.About.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! String
        self.image = UIImage()
        self.animalDescription = object[TableAnimalColumnNames.Species.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! String
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
        
        dispatch_async(Constantes.get_bondzu_queue()){
            print("Loading animal \(object.objectId!)")
            let typeObject = object[TableAnimalColumnNames.UserRequiredType.rawValue] as! PFObject
            do{
                try typeObject.fetchIfNeeded()
                self.requiredPermission = UserType(object: typeObject)
                self.hasLoadedPermission = true
                dispatch_async(dispatch_get_main_queue()){
                    delegate?.animalDidFinishLoadingPermissionType(self)
                }
            }
            catch{
                dispatch_async(dispatch_get_main_queue()){
                    delegate?.animalDidFailedLoadingPermissionType(self)
                }
            }
        }
        
        
    }
    
    
    @available(*, deprecated=9.0, message="Please use the new object constructor!")
    init(){
        name = ""
        specie = ""
        objectId = ""
        adopters = 0
        characteristics = [:]
        about = ""
        animalDescription = ""
    }
    
}


func ==(lhs: AnimalV2, rhs: AnimalV2) -> Bool{
    return lhs.objectId == rhs.objectId
}


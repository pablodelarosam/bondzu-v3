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
    func animalDidFinishLoading(_ animal : AnimalV2)
    
    /**
     Will be called when the animal has failed loading its picture.
     When called the type may not have been loaded yet
     
     - parameter animal: The sending object
     */
    func animalDidFailLoading(_ animal : AnimalV2)
    

    /**
     Will be called when the animal has loaded its required priority.
     
     - parameter animal: The sending object
     */
    func animalDidFinishLoadingPermissionType(_ animal : AnimalV2)
    
    /**
     Will be called when the animal has failed loading its required priority.
     
     - parameter animal: The sending object
     */
    func animalDidFailedLoadingPermissionType(_ animal : AnimalV2)
}


//This class is the model of the Parse class AnimalV2
class AnimalV2 : Equatable
{
   
    ///Array of observers
    fileprivate var callbackArray = Array<((AnimalV2)->())>()
    
    ///Animal image
    var image :  UIImage?
    
    ///Animal name
    var name: String
    
    ///Animal species
    var specie: String
    
    ///Parse ID
    var objectId: String
    
    ///Number of adopter
    var adopters : Int
    
    /**
     A dictionary containing al the facts about an animal
     - key: The description key
     - value: The description itself
     
     Example:
     key = description
     value = beatifull animal
     */
    var characteristics : [String : String]
    
    ///The general description about an animal
    var about : String
    
    ///The original Parse object. Should be used only for querys
    var originalObject : PFObject!
    
    ///Array of keeper objects
    var keepers : [PFObject]?
    
    var requiredPermission : UserType?{
        didSet{
            
            if requiredPermission == nil{ return }
            
            for i in callbackArray{
                i(self)
            }
            
            callbackArray.removeAll()
        }
    }
    
    
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
        self.adopters = (object[TableAnimalColumnNames.Adopters.rawValue] as! NSNumber).intValue
        self.specie = object[TableAnimalColumnNames.Species.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! String
        self.characteristics = object[TableAnimalColumnNames.Characteristics.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! [String:String]
        self.about = object[TableAnimalColumnNames.About.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! String
        self.image = UIImage()
        self.keepers = object[TableAnimalColumnNames.Keepers.rawValue] as? [PFObject]
        
        if delegate != nil || loadImage{
            
            (object[TableAnimalColumnNames.Photo.rawValue] as! PFFile).getDataInBackground(){
                data , error in
                guard error == nil else{
                    print(error!)
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
        
//        Constantes.get_bondzu_queue().async{
//            print("Loading animal \(object.objectId!)")
//            let typeObject = object[TableAnimalColumnNames.UserRequiredType.rawValue] as! PFObject
//            do{
//                try typeObject.fetchIfNeeded()
//                self.requiredPermission = UserType(object: typeObject)
//                self.hasLoadedPermission = true
//                DispatchQueue.main.async{
//                    delegate?.animalDidFinishLoadingPermissionType(self)
//                }
//            }
//            catch{
//                DispatchQueue.main.async{
//                    delegate?.animalDidFailedLoadingPermissionType(self)
//                }
//            }
//        }
        
        
    }
    
    
    @available(*, deprecated: 9.0, message: "Please use the new object constructor!")
    init(){
        name = ""
        specie = ""
        objectId = ""
        adopters = 0
        characteristics = [:]
        about = ""
    }
    
    
    /**
     This function will call the callback only once.
     
     - parameter callback: The closure to be executed when the type has loaded.
     
     ### Important do not capture self
    
     Callback may never be called
     */
    func addObserverToRequiredType(_ callback : @escaping (AnimalV2) -> () ){
        if self.hasLoadedPermission{ callback(self) }
        else{
            callbackArray.append(callback)
        }
    }
    
    
    
}


func ==(lhs: AnimalV2, rhs: AnimalV2) -> Bool{
    return lhs.objectId == rhs.objectId
}


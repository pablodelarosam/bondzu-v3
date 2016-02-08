//
//  Usuario.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 8/27/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//  Archivo Localizado

import UIKit
import Parse

enum UsuarioTransactionResult{
    case Success
    case ParseError
    case AlreadyAdopted
}

class Usuario : NSObject{
    
    var originalObject : PFObject!
    var name : String
    var image : UIImage?
    var stripeID : String
    
    var hasLoadedPriority = false
    
    var type : UserType?
    
    private var typeLoadingObserver = Array<( (Usuario, UserType?) -> (Bool) )>()
    
    /**
        This is the default initializer for a user
     
        - parameter object: The PFObject containing the user.
        - parameter getImage: Ignored if imageLoaderObserver is not null. It tell wether the image will be loaded or not
        - parameter imageLoaderObserver: A observer that tells its delegate when the image have loaded (or failed). If nil is passed as argument and you want to retrive the photo, set fetchImage to true. The observer parameters are described below.
            - Usuario: The object that has finished (or failed) loading.
            - Bool: Its value tells its delegate if the image could be loaded or not.
     
     */
    init(object : PFObject, loadImage : Bool = false,  imageLoaderObserver: ((Usuario, Bool)->(Void))?, userTypeObserver : ((Usuario, UserType?)->(Bool))? = nil ){
        
        self.name = object[TableUserColumnNames.Name.rawValue] as! String
        self.stripeID = object[TableUserColumnNames.StripeID.rawValue] as! String!
        self.originalObject = object
        super.init()
        
        if imageLoaderObserver != nil || loadImage{
            if let image = object[TableUserColumnNames.PhotoFile.rawValue] as? PFFile{
                image.getDataInBackgroundWithBlock({
                    (imageData, error) -> Void in
                    
                    guard error == nil, let unwrapedData = imageData else{
                        dispatch_async(dispatch_get_main_queue()){
                            imageLoaderObserver?(self,false)
                        }
                        print(error)
                        return
                    }
                    
                    self.image = UIImage(data: unwrapedData)
                    
                    if self.image != nil{
                        dispatch_async(dispatch_get_main_queue()){
                            imageLoaderObserver?(self,true)
                        }
                    }
                    else{
                        dispatch_async(dispatch_get_main_queue()){
                            imageLoaderObserver?(self,false)
                        }
                    }
                })
            }
            else if let image = object[TableUserColumnNames.PhotoURL.rawValue] as? String{
                getImageInBackground(url: image, block: { (image, created) -> Void in
                    if(created){
                        self.image = image!
                        dispatch_async(dispatch_get_main_queue()){
                            imageLoaderObserver?(self,true)
                        }
                    }
                    else{
                        dispatch_async(dispatch_get_main_queue()){
                            imageLoaderObserver?(self,false)
                        }
                    }
                })
            }
            else{
                print("Modelo de usuario sin imagen\n \(object.objectId)")
                dispatch_async(dispatch_get_main_queue()){
                    imageLoaderObserver?(self,false)
                }
            }
        }
        
        if let userTypeObserver = userTypeObserver{
            self.typeLoadingObserver.append(userTypeObserver)
        }
        
        dispatch_async(Constantes.get_bondzu_queue()){
            do{
                if let typeObject = object[TableUserColumnNames.UserType.rawValue] as? PFObject{
                    try typeObject.fetch()
                    self.type = UserType(object: typeObject)
                    self.notifyFinishedLoadingUserType()
                }
                else if self.originalObject != PFUser.currentUser(){
                    self.type = Usuario.getSharedBasicType()
                    self.notifyFinishedLoadingUserType()
                }
                else{
                    let query = PFQuery(className: TableNames.UserType.rawValue)
                    query.whereKey(TableUserTypeColumnNames.Priority.rawValue, equalTo: 0)
                    let foundItems = try query.findObjects()
                    self.type = UserType(object: foundItems[0])
                    object[TableUserColumnNames.UserType.rawValue] = Usuario.getSharedBasicType()
                    try object.save()
                    self.notifyFinishedLoadingUserType()
                }
            }
            catch{
                self.notifyFinishedLoadingUserType()
            }
        }
    }
    
    
    /**
     This method updates the user profile image. The process will be held asyncronuslly by the function and the result will be informed trought a callback
     
     - parameter image: The image that is going to be used by the user.
     - parameter callback: The function to call when the update is done.
     
     #### Note: callback will be called on the main thread ####
     
     */
    func setNewProfileImage(image : UIImage , callback : ((Bool)->Void)){
        let file = PFFile(data: UIImagePNGRepresentation(image)!)
        originalObject[TableUserColumnNames.PhotoURL.rawValue] = NSNull()
        originalObject[TableUserColumnNames.PhotoFile.rawValue] = file
        originalObject.saveInBackgroundWithBlock({
            (_, error) -> Void in
            dispatch_async(dispatch_get_main_queue()){
                if error != nil{
                    callback(false)
                }
                else{
                    callback(true)
                }
            }
        })
    }
    
    
    /** 
    This function attemp to save a new adoption.
     
    The value is returned after a lot of web requests so THIS METHOD SHOULD BE CALLED IN BACKGROUND.
        
    - parameter animal: The Parse object id of the animal to adopt.
    - parameter user: The user making the adoption. If none is specified the current user is selected.
    
    - returns: 0 in case the transaction succeds. 1 in case there were a Parse Error. 2
    */
    class func adoptAnimal(animalID : String, user : PFUser = PFUser.currentUser()!) -> UsuarioTransactionResult{

        if(NSThread.isMainThread()){
            mainThreadWarning()
        }
        
        let relation = user.relationForKey(TableUserColumnNames.AdoptedAnimalsRelation.rawValue)
        let query = relation.query()
       
        do{
            let animals = try query.findObjects()
            
            //Check if the animal is already adopted
            for animal in animals{
                if (animal).objectId == animalID{
                    return UsuarioTransactionResult.AlreadyAdopted
                }
            }
            
            let relation = user.relationForKey(TableUserColumnNames.AdoptedAnimalsRelation.rawValue)
            relation.addObject(PFObject(withoutDataWithClassName: TableNames.Animal_table.rawValue, objectId: animalID))
            try user.save()
            
            let animal = PFObject(withoutDataWithClassName: TableNames.Animal_table.rawValue, objectId: animalID)
            animal.incrementKey(TableAnimalColumnNames.Adopters.rawValue, byAmount: 1)
            //No need to fecth this result
            animal.saveEventually()
            return UsuarioTransactionResult.Success
            
        }
        catch{
            print("Error in Usuario.adopt: \(error)")
            return UsuarioTransactionResult.ParseError
        }
        
    }
    
    
    /**
     This function attemp to get a
     
     The value is returned after a lot of web requests so THIS METHOD SHOULD BE CALLED IN BACKGROUND.
     
     - parameter imageDelegate: This method will pass the delegate to animal objects in case you want to know when they are fully loaded
     
     - returns: a bool telling if the operation succeded and an array of adopted animals in case of success
     */
    func getAdoptedAnimals(imageDelegate : AnimalV2LoadingProtocol?) -> (Bool , [AnimalV2]?){
        if(NSThread.isMainThread()){
            mainThreadWarning()
        }
        
        let relation = originalObject.relationForKey(TableUserColumnNames.AdoptedAnimalsRelation.rawValue)
        let query = relation.query()
        
        do{
            let animals = try query.findObjects()
            var adopted = [AnimalV2]()
            
            for animal in animals{
                adopted.append(AnimalV2(object: animal, delegate: imageDelegate))
            }

            return (true, adopted)
        }
        catch{
            print(error)
            return (false, nil)
        }
    }
    
    /**
     This method is provided for the objects that want to be informed about changes in the user type. There are two rules for the observer:
     1. The observer must not have strong references or its going to create memory leaks
     2. The closure should return if it should be kept as observer
     */
    func appendTypeLoadingObserver(observer : (Usuario, UserType?) -> (Bool)){
        if self.hasLoadedPriority{
            observer(self,type)
        }
        else{
            typeLoadingObserver.append(observer)
        }
    }
    
    private func notifyFinishedLoadingUserType(){
        
        if self.type != nil{
            hasLoadedPriority = true
        }
        
        if !NSThread.isMainThread(){
            
            dispatch_async(dispatch_get_main_queue()){
                self.notifyFinishedLoadingUserType()
            }
            
        }
        else{
            
            var i = 0;
            while i < self.typeLoadingObserver.count{
                if !self.typeLoadingObserver[i](self, self.type){
                    _ = self.typeLoadingObserver.removeAtIndex(i)
                }
                else{
                    i++
                }
            }
            
            for userTypeObserver in self.typeLoadingObserver{
                userTypeObserver(self, self.type)
            }
            
        }
    }
    
    func refreshUserType(){
        dispatch_async(Constantes.get_bondzu_queue()){
            do{
                try self.originalObject.fetch()
                let typeObject = self.originalObject[TableUserColumnNames.UserType.rawValue] as! PFObject
                try typeObject.fetch()
                self.type = UserType(object: typeObject)
                dispatch_async(dispatch_get_main_queue()){
                    self.notifyFinishedLoadingUserType()
                }
            }
            catch{
                dispatch_async(dispatch_get_main_queue()){
                    self.notifyFinishedLoadingUserType()
                }
            }
        }
    }
    
    class func needsUpdating(object : PFObject)->Bool{
        if let _ = object[TableUserColumnNames.UserType.rawValue] as? PFObject{
            return false
        }
        
        return true
    }
    
    func userNeededTypeForRequestedPermission(permission : Int, callback : (UserType?)->() ){
        dispatch_async(Constantes.get_bondzu_queue()){
            do{
                let query = PFQuery(className: TableNames.UserType.rawValue)
                query.whereKey(TableUserTypeColumnNames.Purchasable.rawValue, equalTo: true)
                query.whereKey(TableUserTypeColumnNames.Priority.rawValue, greaterThanOrEqualTo: permission)
                let array = try query.findObjects()
                
                if array.isEmpty{
                    throw Errors.GenericError
                }
                
                dispatch_async(dispatch_get_main_queue()){
                    callback(UserType(object: array[0]))
                }
            }
            catch{
                dispatch_async(dispatch_get_main_queue()){
                    callback(nil)
                }
            }
            
        }
    }
    
    
    ///Do not call directly. Use getSharedBasicType
    static var sharedBasicType : UserType?
    
    ///#Call in background
    class func getSharedBasicType()->UserType?{
        
        
        if NSThread.isMainThread(){
            mainThreadWarning()
        }
        
        if let s = sharedBasicType{
            return s
        }
        
        do{
            let query = PFQuery(className: TableNames.UserType.rawValue)
            query.whereKey(TableUserTypeColumnNames.Priority.rawValue, equalTo: 0)
            let foundItems = try query.findObjects()
            Usuario.sharedBasicType = UserType(object: foundItems[0])
            return getSharedBasicType()
            
        }
        catch{
            return nil
            
        }
    }
}

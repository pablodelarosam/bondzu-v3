//
//  Usuario.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 8/27/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//  Archivo Localizado

import UIKit
import Parse

class Usuario: NSObject {
    
    var name : String
    var image : UIImage?

    
    /**
        This is the default initializer for a user
     
        - parameter object: The PFObject containing the user.
        - parameter imageLoaderObserver: A observer that tells its delegate when the image have loaded (or failed). The observer parameters are described below.
            - Usuario: The object that has finished (or failed) loading.
            - Bool: Its value tells its delegate if the image could be loaded or not.
     
    */
    init(object : PFObject, imageLoaderObserver: ((Usuario, Bool)->(Void))?){
        self.name = object[TableUserColumnNames.Name.rawValue] as! String
        super.init()
        //WARNING: Esto no se hace. Arregla el issue #44 pero se debe hacer ben cambiando el frame de lateral about view
        self.image = UIImage()
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
                    }                }
                else{
                    dispatch_async(dispatch_get_main_queue()){
                        imageLoaderObserver?(self,false)
                    }
                }
            })
        }
        else{
            print("Modelo de usuario incompleto\n \(object.objectId)")
            dispatch_async(dispatch_get_main_queue()){
                imageLoaderObserver?(self,false)
            }
        }
    }
    
    @available(*, deprecated=8.0, message="Now each model is responsable for its data model. Please call PFObject initializer")
    init(name : String , photo : String){
        self.name = name
        super.init()
    }
    
    @available(*, deprecated=8.0, message="Now each model is responsable for its data model. Please call PFObject initializer")
    init(name : String , photoFile : PFFile){
        self.name = name
        super.init()
        photoFile.getDataInBackgroundWithBlock {
            (imgData, error) -> Void in
            if error != nil{
                print("error obtiendo imagen: \(error)")
                return
            }
        }
    }
    
    init(name : String) {
        self.name = name
    }
}

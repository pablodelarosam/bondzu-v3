//
//  Gallery.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 12/7/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//

import UIKit
import Parse

protocol GalleryLoadingProtocol{
    func galleryImageDidFinishLoading(gallery : Gallery)
    func galleryImageDidFailLoading(gallery : Gallery)
}

class Gallery{
    
    let animalID : String
    let imageFile : PFFile
    var image : UIImage?
    
    /**
     - parameter object: The PFObject to parse.
     - parameter delegate: The delegate to notify when the image is ready.
     - parameter loadImage: This parameter will be only taken in mind if the delegate is nil. It tells the wether the associated image is loaded or notociated image. The default value is false
     
     */
    init(object : PFObject, delegate : GalleryLoadingProtocol?, loadImage : Bool = false ){

        let animalObject = object[TableGalleryColumnNames.Animal.rawValue] as! PFObject
        self.animalID =  animalObject.objectId!
        self.imageFile = object[TableGalleryColumnNames.Image.rawValue] as! PFFile
        
        //Determine if the image should be loaded or not
        if delegate != nil || loadImage{
            
            //Download the image and notify delegate
            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
                do{
                    let data = try self.imageFile.getData()
                    self.image = UIImage(data: data)
                    dispatch_async(dispatch_get_main_queue()){
                        if self.image == nil{
                            print("Invalid data in gallery file with animalID \(self.animalID)");
                            delegate?.galleryImageDidFailLoading(self)
                        }
                        else{
                            delegate?.galleryImageDidFinishLoading(self)
                        }
                    }
                } //End do
                catch{
                    dispatch_async(dispatch_get_main_queue()){
                        print("Error getting image \(error)")
                        delegate?.galleryImageDidFailLoading(self)
                    }
                }//End catch
            } //End async block
        } // End determine if the image should be downloaded
        else{ //Should not download or image data invalid
            delegate?.galleryImageDidFailLoading(self)
        }
        
    } //End constructor
    
} //End class

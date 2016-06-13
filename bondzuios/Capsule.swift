//
//  Capsula.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 10/8/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//  Archivo Localizado

import UIKit
import Parse

@objc protocol CapsuleLoadingDelegate{
    func capsuleDidFinishLoading(capsule : Capsule)
    func capsuleDidFailLoading(capsule : Capsule)
    func capsuleDidLoadRequiredType(capsule : Capsule)
    func capsuleDidFailLoadingRequiredType(capsule : Capsule)
}

class Capsule : NSObject{
    
    class func videoPattern(id : String) -> String{
        return "https://img.youtube.com/vi/\(id)/mqdefault.jpg"
    }
    
    
    class func secondTryVideoPattern(id : String) -> String{
        return "https://img.youtube.com/vi/\(id)/mqdefault_live.jpg"
    }
    
    var videoID : [String]
    var title : [String]
    var videoDescription : [String]
    var animalName : String = ""
    var animalId : String = ""
    var publishedOn : NSDate
    var image : UIImage!
    weak var delegate : CapsuleLoadingDelegate?
    
    var hasLoadedPriority = false
    var requiredPriority : UserType?
    
    init(object : PFObject, delegate : CapsuleLoadingDelegate?){
        videoID = object[TableVideoCapsuleNames.YoutubeID.rawValue] as! [String]
        title = object[TableVideoCapsuleNames.Title.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! [String]
        videoDescription = object[TableVideoCapsuleNames.Description.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! [String]
        publishedOn = object.updatedAt!
        self.delegate = delegate
        
        super.init()
        
        let animal = object[TableVideoCapsuleNames.AnimalID.rawValue] as! PFObject
        animal.fetchInBackgroundWithBlock {
            (av2, error) -> Void in
            if error != nil{
                self.delegate?.capsuleDidFailLoading(self)
                self.delegate = nil
                return
            }
            
            let animal = AnimalV2(object: av2!, delegate: nil)
            self.animalName = animal.name
            self.animalId = animal.objectId
            let img = Capsule.videoPattern(self.videoID[0])
            let eimg = Capsule.secondTryVideoPattern(self.videoID[0])
            getImageInBackground(url: img){
                (image, completed) -> Void in
                
                if !completed{
                    getImageInBackground(url: eimg, block: {
                        (img, complete) -> Void in
                        if !complete{
                            self.delegate?.capsuleDidFailLoading(self)
                            self.delegate = nil
                            return
                        }
                        
                        self.image = img
                        self.delegate?.capsuleDidFinishLoading(self)
                        self.delegate = nil
                    })
                    return
                }
                
                self.image = image
                self.delegate?.capsuleDidFinishLoading(self)
                self.delegate = nil
            }
            
        }
        
        dispatch_async(Constantes.get_bondzu_queue()){
            do{
                print("Loading video \(object.objectId!)")
                let typeObject = object[TableVideoCapsuleNames.UserRequiredType.rawValue] as! PFObject
                try typeObject.fetchIfNeeded()
                self.requiredPriority = UserType(object: typeObject)
                self.hasLoadedPriority = true
                
                dispatch_async(dispatch_get_main_queue()){
                    delegate?.capsuleDidLoadRequiredType(self)
                }
                
            }
            catch{
                dispatch_async(dispatch_get_main_queue()){
                    delegate?.capsuleDidFailLoadingRequiredType(self)
                }
            }
        }
        
    }
}

func ==(lhs: Capsule, rhs: Capsule) -> Bool{
    return lhs.videoID[0] == rhs.videoID[0]
}

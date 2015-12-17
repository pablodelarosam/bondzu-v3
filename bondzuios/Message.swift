//
//  Message.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 12/14/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//

import UIKit

@objc protocol LoadMessageResult{
    
    func UserDidLoad(message : Message)
    func UserDidFailedLoading(message : Message)

    func UserImageDidFinishLoading( message : Message )
    func UserImageDidFailedLoading( message : Message )

}

class Message : NSObject{
    
    private var attachedPhotoFile : PFFile?
    var date : NSDate
    var message : String
    var animal : AnimalV2
    var user : Usuario?
    var likes : [String]!
    var hasAttachedImage : Bool
    var originalObject : PFObject
    
    var identifier : String!
    
    
    init( object : PFObject, loadUserImage : Bool = false, delegate : LoadMessageResult?){
        originalObject = object
        attachedPhotoFile = object[TableMessagesColumnNames.Photo.rawValue] as? PFFile
        date = object.createdAt!
        message = object[TableMessagesColumnNames.Message.rawValue] as! String
        animal = AnimalV2(object: object[TableMessagesColumnNames.Animal.rawValue] as! PFObject, delegate: nil, loadImage: false)
        identifier = object.objectId
        hasAttachedImage = !(attachedPhotoFile == nil)
        
        super.init()
        
        if let likesArray = object[TableMessagesColumnNames.LikesRelation.rawValue] as? [String]{
            likes = likesArray
        }
        
       
        if likes == nil{
            upgradeMessageLikes(object)
        }
       
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
            do{
                let userObject = object[TableMessagesColumnNames.User.rawValue] as! PFObject
                try userObject.fetch()
                self.user = Usuario(object: userObject, imageLoaderObserver:
                    { (_, fetched) -> (Void) in
                        if fetched{
                            delegate?.UserImageDidFinishLoading(self)
                        }
                        else{
                            delegate?.UserImageDidFailedLoading(self)
                        }
                })
                dispatch_async(dispatch_get_main_queue()){
                    delegate?.UserDidLoad(self)
                }
            }
            catch{
                dispatch_async(dispatch_get_main_queue()){
                    delegate?.UserDidFailedLoading(self)
                }
            }
        }
    }
    
    func attachedFile()->PFFile?{
        return attachedPhotoFile
    }
    
    func userHasLiked(user : Usuario)->Bool{
        return likes.contains(user.originalObject.objectId!)
    }
    
    func likesCount()->Int{
        return likes.count
    }
    
    func upgradeMessageLikes(object : PFObject){
        likes = [String]()
        object[TableMessagesColumnNames.LikesRelation.rawValue] = likes
        object.saveEventually()
    }
    
}

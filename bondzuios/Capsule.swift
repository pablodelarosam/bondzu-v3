//
//  Capsula.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 10/8/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//  Archivo Localizado

import UIKit
import Parse

protocol CapsuleLoadingDelegate{
    func capsuleDidFinishLoading(capsule : Capsule)
    func capsuleDidFailLoading(capsule : Capsule)
}

class Capsule : Equatable{
    
    class func videoPattern(id : String) -> String{
        return "https://img.youtube.com/vi/\(id)/mqdefault.jpg"
    }
    
    var videoID : [String]
    var title : [String]
    var videoDescription : [String]
    var animalName : String = ""
    var publishedOn : NSDate
    var image : UIImage!
    var delegate : CapsuleLoadingDelegate?
    
    
    init(object : PFObject, delegate : CapsuleLoadingDelegate?){
        videoID = object[TableVideoCapsuleNames.YoutubeID.rawValue] as! [String]
        title = object[TableVideoCapsuleNames.Title.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! [String]
        videoDescription = object[TableVideoCapsuleNames.Description.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! [String]
        publishedOn = object.updatedAt!
        self.delegate = delegate
        let animal = object[TableVideoCapsuleNames.AnimalID.rawValue] as! PFObject
        animal.fetchInBackgroundWithBlock {
            (av2, error) -> Void in
            if error != nil{
                self.delegate?.capsuleDidFailLoading(self)
                self.delegate = nil
                return
            }
            self.animalName = av2![TableAnimalColumnNames.Name.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! String
            let img = Capsule.videoPattern(self.videoID[0])
            //WARNING: fix this unused value
            getImageInBackground(url: img){
                (image, completed) -> Void in
                self.image = image
                self.delegate?.capsuleDidFinishLoading(self)
                self.delegate = nil
            }
            
        }
    }
}

func ==(lhs: Capsule, rhs: Capsule) -> Bool{
    return lhs.videoID[0] == rhs.videoID[0]
}

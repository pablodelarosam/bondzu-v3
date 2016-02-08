//
//  Camera.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 12/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//  Archivo Localizado

import Foundation
import Parse

/**
This class provides the model for the live stream cameras
*/
@objc class Camera : NSObject
{
    
    /**
    Get the parse assigned object id. This can be used to perform queries
     */
    var objectId: String!{
        get{
            return originalObject.objectId!
        }
    }
    
    ///The original parse object that was passed to the constructor
    private var originalObject : PFObject
    
    ///The camera description
    var descripcion: String!;
    
    ///The parse assigned animal id
    var animalId: String!;
    
    ///The name of the animal that this camera belongs to
    var animalName: String!;
    
    ///Describes if the camera is working or not
    var funcionando: Bool!;
    
    ///The camera url to the hls protocol
    var url: NSURL?;
    
    private var timer : NSDate?
    private var oldTime = 0
    private var multiplier = 1
    private var instances = 0
    
    /**
     This method is the default constructor for the class. Ittakes a Parse object and it acces to all the required information from it. 
     The only rule is that in order for the object to be correclty accesed the object needs to be fetched.
     
     - parameter object: The parse object that represents a camera
     */
    init(object : PFObject){
        self.originalObject = object
        self.descripcion = object[TableCameraColumnNames.Description.rawValue] as! String
        self.animalId = (object[TableCameraColumnNames.Animal.rawValue] as! PFObject).objectId!
        self.animalName = object[TableCameraColumnNames.AnimalName.rawValue] as! String
        self.funcionando = object[TableCameraColumnNames.Working.rawValue] as! Bool
        self.url = NSURL(string: object[TableCameraColumnNames.PlayBackURL.rawValue] as! String)
    }
    
    
    /**
     This method should be called when the camera starts streaming.
     There can be many calls to this method but all of them should be terminated by calling *stopWatchingVideo()*
     
     This method is provided to feed the statistcs engine of the database
     */
    func startWatchingVideo(){
        if instances == 0{
            multiplier = 1
            oldTime = 0
            instances = 1
            timer = NSDate()
        }
        else{
            moveToOldTime()
            multiplier++
            instances++
        }
    }
    
    
    /**
     This method should be called when the camera stops streaming.
     There can be many calls to this method but all of them should be terminated by calling *stopWatchingVideo()*
     
     This method is provided to feed the statistcs engine of the database
     */
    func stopWatchingVideo(){
        if instances == 0{ return }
        else if instances > 1{
            moveToOldTime()
            instances--
            multiplier--
        }
        else{
            moveToOldTime()
            instances = 0
            
            self.originalObject.incrementKey(TableCameraColumnNames.StatisticTime.rawValue, byAmount: oldTime)
            self.originalObject.saveInBackground()
        }
    }
    
    /**
     This method should be called when start watching video will manage more than one timer or when stop watching video is called.
     
     This method will calculate how many seconds have passed and will move it to the variable *oldTime*
     
     This method will also "reset" the timer
     */
    private func moveToOldTime(){
        let end = NSDate()
        let seconds = end.timeIntervalSinceDate(timer!)
        oldTime += ( Int(seconds) * multiplier )
        timer = end
    }
    
}
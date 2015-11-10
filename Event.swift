//
//  Event.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 10/6/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//  Archivo Localizado

import UIKit
import Parse

@objc
protocol EventLoadingDelegate{
    func eventDidFailLoading(event : Event!)
    func eventDidFinishLoading(event : Event!)
}


class Event: NSObject {

    weak var delegate : EventLoadingDelegate?
    
    var eventName = ""
    var eventDescription = ""
    var startDate = NSDate()
    var endDate = NSDate()
    var eventImage = UIImage()
    
    
    init(object : PFObject , delegate : EventLoadingDelegate? = nil){
        
        super.init()
        self.delegate = delegate
        
        eventName = object[TableEventsColumnNames.Name.rawValue +  NSLocalizedString(LOCALIZED_STRING, comment: "")] as! String
        eventDescription = object[TableEventsColumnNames.Description.rawValue +  NSLocalizedString(LOCALIZED_STRING, comment: "")] as! String

        startDate = object[TableEventsColumnNames.Start_Day.rawValue] as! NSDate
        endDate = object[TableEventsColumnNames.End_Day.rawValue ] as! NSDate
        
        let file = object[TableEventsColumnNames.Image_Name.rawValue] as! PFFile
        
        file.getDataInBackgroundWithBlock { (data, error) -> Void in
            if error == nil && data != nil{
                dispatch_async(dispatch_get_main_queue()){
                    self.eventImage = UIImage(data: data!)!
                    self.delegate?.eventDidFinishLoading(self)
                    self.delegate = nil
                }
            }
            else{
                print(error)
                self.delegate?.eventDidFailLoading(self)
                self.delegate = nil
            }
        }
    }

}

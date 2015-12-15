//
//  Reply.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 12/14/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//

import UIKit

protocol LoadReplyResult{
    
    func UserImageDidFinishLoading( reply : Reply )
    func UserImageDidFailedLoading( reply : Reply )
    
    func UserDidLoad( reply : Reply )
    func UserDidFailedLoading( reply : Reply )
}


class Reply: NSObject {
    
    var parent : Message
    var user : Usuario?
    var message : String
    var date : NSDate
    
    
    init(object : PFObject, delegate : LoadReplyResult?) {
        parent = Message(object: object[TableReplyColumnNames.ParentMessage.rawValue] as! PFObject, delegate: nil)
        message = object[TableReplyColumnNames.Message.rawValue] as! String
        date = object.createdAt!
        super.init()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
            
            do{
                let userObject = object[TableReplyColumnNames.User.rawValue] as! PFObject
                try userObject.fetch()
                self.user = Usuario(object: userObject){
                    (user, boolean) -> (Void) in
                    if(boolean){
                        delegate?.UserImageDidFinishLoading(self)
                    }
                    else{
                        delegate?.UserImageDidFailedLoading(self)
                    }
                }
                
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
    
}

//
//  Reply.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 12/14/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//

import UIKit

protocol LoadReplyResult{
    
    func UserImageDidFinishLoading( _ reply : Reply )
    func UserImageDidFailedLoading( _ reply : Reply )
    
    func UserDidLoad( _ reply : Reply )
    func UserDidFailedLoading( _ reply : Reply )
}


class Reply: NSObject {
    
    var parent : Message
    var user : Usuario?
    var message : String
    var date : Date
    
    
    init(object : PFObject, delegate : LoadReplyResult?) {
        parent = Message(object: object[TableReplyColumnNames.ParentMessage.rawValue] as! PFObject, delegate: nil)
        message = object[TableReplyColumnNames.Message.rawValue] as! String
        date = object.createdAt!
        super.init()
        Constantes.get_bondzu_queue().async(){
            
            do{
                let userObject = object[TableReplyColumnNames.User.rawValue] as! PFObject
                try userObject.fetch()
                self.user = Usuario(object: userObject, imageLoaderObserver: {
                    (user, boolean) -> (Void) in
                    if(boolean){
                        delegate?.UserImageDidFinishLoading(self)
                    }
                    else{
                        delegate?.UserImageDidFailedLoading(self)
                    }
                })
                
                DispatchQueue.main.async(){
                    delegate?.UserDidLoad(self)
                }
            }
            catch{
                DispatchQueue.main.async(){
                    delegate?.UserDidFailedLoading(self)
                }
            }
        }
    }
    
}

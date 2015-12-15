//
//  CommunityTabHelper.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 12/14/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//

import UIKit
import MessageUI

@objc enum CommunityOperation : Int{
    case like
    case email
}

@objc protocol CommunityTabHelperProtocol{

    func operationDidSucceded( message : Message, operation : CommunityOperation )
    func operationDidFailed( message : Message, operation : CommunityOperation  )

}

class CommunityTabHelper: NSObject, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate{
 
    weak var delegate : CommunityTabHelperProtocol?
    var message : Message!

    func like(message : Message, like : Bool, user : Usuario, delegate : CommunityTabHelperProtocol?){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
            do{
                if like{
                    message.originalObject.addUniqueObject(user.originalObject.objectId!, forKey: TableMessagesColumnNames.LikesRelation.rawValue)
                    try message.originalObject.save()
                    message.likes.append(user.originalObject.objectId!)
                }
                else{
                    message.originalObject.removeObject(user.originalObject.objectId!, forKey: TableMessagesColumnNames.LikesRelation.rawValue)
                    try message.originalObject.save()
                    
                    if let index = message.likes.indexOf(user.originalObject.objectId!){
                        message.likes.removeAtIndex(index)
                    }
                    
                    
                }
                dispatch_async(dispatch_get_main_queue()){
                    delegate?.operationDidSucceded(message, operation: CommunityOperation.like)
                }
            }
            catch{
                dispatch_async(dispatch_get_main_queue()){
                    delegate?.operationDidFailed(message, operation: CommunityOperation.like)
                }
            }
        }
    }
    
    func report(delegate : CommunityTabHelperProtocol?, message : Message, fromViewController: UIViewController){
        
        self.delegate = delegate
        
        if(!MFMailComposeViewController.canSendMail()){
            let a = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Your device is not configured to send mail", comment: ""), preferredStyle: .Alert)
            a.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
            fromViewController.presentViewController(a, animated: true, completion: nil)
            delegate?.operationDidFailed(message, operation: .email)
            return
        }
        
        //reports@bondzu.com
        let controller = MFMailComposeViewController()
        controller.setToRecipients(["reports@bondzu.com"])
        controller.setSubject(NSLocalizedString("Inappropriate message", comment: ""))
        controller.setMessageBody(NSLocalizedString("Hello.\nI think this message is inappropiate\n\n[Please do no dot delete this information]\nMessage id:", comment: "") + " \(message.identifier)", isHTML: false)
        controller.delegate = self
        controller.mailComposeDelegate = self
        fromViewController.presentViewController(controller, animated: true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?){
        controller.dismissViewControllerAnimated(true, completion: nil)
        if result == MFMailComposeResultSent{
            delegate?.operationDidSucceded(message, operation: .email)
        }
        else{
            delegate?.operationDidFailed(message, operation: .email)
        }
    }
    
    func showImage(message: Message, fromViewController : UIViewController) {
        
        guard message.hasAttachedImage else{
            return
        }
        
        let i = FullImageViewController()
        fromViewController.parentViewController!.presentViewController(i, animated: true, completion: nil)
        i.loadParseImage(message.attachedFile()!)
        
    }
    
}

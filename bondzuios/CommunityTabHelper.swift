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

    func operationDidSucceded( _ message : Message, operation : CommunityOperation )
    func operationDidFailed( _ message : Message, operation : CommunityOperation  )

}

class CommunityTabHelper: NSObject, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate{
 
    weak var delegate : CommunityTabHelperProtocol?
    var message : Message!

    var dismiser : InteractiveDismissalHelper?
    
    func like(_ message : Message, like : Bool, user : Usuario, delegate : CommunityTabHelperProtocol?){
        Constantes.get_bondzu_queue().async{
            do{
                if like{
                    message.originalObject.addUniqueObject(user.originalObject.objectId!, forKey: TableMessagesColumnNames.LikesRelation.rawValue)
                    try message.originalObject.save()
                    message.likes.append(user.originalObject.objectId!)
                }
                else{
                    message.originalObject.remove(user.originalObject.objectId!, forKey: TableMessagesColumnNames.LikesRelation.rawValue)
                    try message.originalObject.save()
                    
                    if let index = message.likes.index(of: user.originalObject.objectId!){
                        message.likes.remove(at: index)
                    }
                    
                    
                }
                DispatchQueue.main.async{
                    delegate?.operationDidSucceded(message, operation: CommunityOperation.like)
                }
            }
            catch{
                DispatchQueue.main.async{
                    delegate?.operationDidFailed(message, operation: CommunityOperation.like)
                }
            }
        }
    }
    
    func report(_ delegate : CommunityTabHelperProtocol?, message : Message, fromViewController: UIViewController){
        
        self.delegate = delegate
        
        if(!MFMailComposeViewController.canSendMail()){
            let a = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Your device is not configured to send mail", comment: ""), preferredStyle: .alert)
            a.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
            fromViewController.present(a, animated: true, completion: nil)
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
        fromViewController.present(controller, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?){
        controller.dismiss(animated: true, completion: nil)
        if result == MFMailComposeResult.sent{
            delegate?.operationDidSucceded(message, operation: .email)
        }
        else{
            delegate?.operationDidFailed(message, operation: .email)
        }
    }
    
    func showImage(_ message: Message, fromViewController : UIViewController) {
        
        guard message.hasAttachedImage else{
            return
        }
        
        
        let i = FullImageViewController()
        fromViewController.parent!.present(i, animated: true, completion: nil)
        i.loadParseImage(message.attachedFile()!)
        
        dismiser = InteractiveDismissalHelper()
        dismiser!.wireToViewController(i)
        
    }
    
}

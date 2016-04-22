//
//  AboutUsViewController.swift
//  bondzuios
//
//  Created by Daniela Becerra on 13/04/16.
//  Copyright © 2016 Bondzu. All rights reserved.
//

import UIKit
import MessageUI

class AboutUsViewController:  UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {

     @IBOutlet weak var blurView: UIVisualEffectView!
  
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
     }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 2
        }
        return 1;
        
     }
    
     func tableView(tableView: UITableView,cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            
            
            let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
            cell.textLabel!.textColor = UIColor.whiteColor()
            cell.backgroundColor = UIColor.clearColor()
            cell.tintColor = UIColor.redColor()
            
            switch indexPath.row{
            case 0:
                cell.textLabel!.text = NSLocalizedString("History", comment: "")
            case 1:
                cell.textLabel!.text = NSLocalizedString("Team", comment: "")
            default:
                cell.textLabel!.text = NSLocalizedString("Contact us", comment: "")
            }
            
            
            cell.accessoryType = .DisclosureIndicator
            cell.imageView?.tintColor = UIColor.whiteColor()
            cell.imageView?.image = iconForCellAtIndexPath(indexPath.section, row: indexPath.row)
            
            return cell
        }
        else{
            let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
            cell.textLabel!.text = NSLocalizedString("Contact us", comment: "")
            cell.backgroundColor = UIColor.clearColor()
            cell.textLabel!.textColor = UIColor.whiteColor()
            cell.imageView?.tintColor = UIColor.whiteColor()
            cell.imageView?.image = iconForCellAtIndexPath(indexPath.section, row: indexPath.row)
            return cell
        }
    }
    
    //icons
    func iconForCellAtIndexPath(section : Int, row : Int) -> UIImage!{
        var image : UIImage
        
        if section == 1{
            image = UIImage(named: "contacto")!
        }
        else{
            switch row{
            case 0:
                image =  UIImage(named: "historia")!
            case 1:
                image = UIImage(named: "equipo")!
            default: return nil;
            }
        }
        
        image = image.imageWithRenderingMode(.AlwaysTemplate)
        return image
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }

    func tableView(tableView: UITableView,  viewForFooterInSection section: Int) -> UIView? {
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor.clearColor()
        return separatorView
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1{
            //send email
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
        }
        else if indexPath.row == 0{
            performSegueWithIdentifier("historia", sender: nil)
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
        else if indexPath.row == 1{
            performSegueWithIdentifier("equipo", sender: nil)
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
        
    }
    
 //// tableview methods end
    
    
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blurView.layer.cornerRadius = 10.0
        blurView.layer.masksToBounds = true
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    @IBAction func playWasPressed(sender: AnyObject) {
        //playVideo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
   
    
//send email ///////////////////////////////////////
        func configuredMailComposeViewController() -> MFMailComposeViewController {
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
            
            mailComposerVC.setToRecipients(["hello@bondzu.com"])
            //mailComposerVC.setSubject("Sending you an in-app e-mail...")
            //mailComposerVC.setMessageBody("Sending e-mail in-app is not so bad!", isHTML: false)
            
            return mailComposerVC
        }
        
        func showSendMailErrorAlert() {
            print("error sending email")
            //            let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
//            sendMailErrorAlert.show()
        }
        
        // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }


}

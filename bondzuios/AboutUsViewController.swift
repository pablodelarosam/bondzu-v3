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
  
     func numberOfSections(in tableView: UITableView) -> Int {
        return 2
     }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 2
        }
        return 1;
        
     }
    
     func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            
            
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel!.textColor = UIColor.white
            cell.backgroundColor = UIColor.clear
            cell.tintColor = UIColor.red
            let backView = UIView(frame: cell.frame)
            backView.backgroundColor = UIColor(hexString: "DD7A25") //naranja
            cell.selectedBackgroundView = backView
            
            switch indexPath.row{
            case 0:
                cell.textLabel!.text = NSLocalizedString("History", comment: "")
            case 1:
                cell.textLabel!.text = NSLocalizedString("Team", comment: "")
            default:
                cell.textLabel!.text = NSLocalizedString("Contact us", comment: "")
            }
            
            
            cell.accessoryType = .disclosureIndicator
            cell.imageView?.tintColor = UIColor.white
            cell.imageView?.image = iconForCellAtIndexPath(indexPath.section, row: indexPath.row)
            
            return cell
        }
        else{
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel!.text = NSLocalizedString("Contact us", comment: "")
            cell.backgroundColor = UIColor.clear
            cell.textLabel!.textColor = UIColor.white
            cell.imageView?.tintColor = UIColor.white
            cell.imageView?.image = iconForCellAtIndexPath(indexPath.section, row: indexPath.row)
            return cell
        }
    }
    
    //icons
    func iconForCellAtIndexPath(_ section : Int, row : Int) -> UIImage!{
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
        
        image = image.withRenderingMode(.alwaysTemplate)
        return image
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }

    func tableView(_ tableView: UITableView,  viewForFooterInSection section: Int) -> UIView? {
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor.clear
        return separatorView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            //send email
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
        }
        else if indexPath.row == 0{
            performSegue(withIdentifier: "historia", sender: nil)
            tableView.deselectRow(at: indexPath, animated: false)
        }
        else if indexPath.row == 1{
            performSegue(withIdentifier: "equipo", sender: nil)
            tableView.deselectRow(at: indexPath, animated: false)
        }
        
    }
    
 //// tableview methods end
    
    
    
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blurView.layer.cornerRadius = 10.0
        blurView.layer.masksToBounds = true
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    @IBAction func playWasPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "video", sender: nil)
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
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }


}

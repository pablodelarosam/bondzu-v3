//
//  AccountViewController.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 9/28/15.
//  Copyright © 2015 Bondzu. All rights reserved.
// ARCHIVO LOCALIZADO


import UIKit
import Parse
import MobileCoreServices

/**
 This class provides the table
 */
class AccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var user : Usuario?
    
    @IBOutlet weak var animalEffectView: EffectBackgroundView!
    @IBOutlet weak var imageView: UserView!
    @IBOutlet weak var name: UILabel!

    var originalImage : UIImage?
    
    var changedImage = false
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 3
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
                 cell.textLabel!.text = NSLocalizedString("Adoptions", comment: "")
            case 1:
                 cell.textLabel!.text = NSLocalizedString("Activity", comment: "")
            case 2:
                 cell.textLabel!.text = NSLocalizedString("Payment", comment: "")
            default:
                cell.textLabel!.text = NSLocalizedString("Logout", comment: "")
            }
            
            
            cell.accessoryType = .DisclosureIndicator
            cell.imageView?.tintColor = UIColor.whiteColor()
            cell.imageView?.image = iconForCellAtIndexPath(indexPath.section, row: indexPath.row)
            
            return cell
        }
        else{
            let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
            cell.textLabel!.text = NSLocalizedString("Logout", comment: "")
            cell.backgroundColor = UIColor.clearColor()
            cell.textLabel!.textColor = UIColor.whiteColor()
            cell.imageView?.tintColor = UIColor.whiteColor()
            cell.imageView?.image = iconForCellAtIndexPath(indexPath.section, row: indexPath.row)
            return cell
        }
    }
    
    /**
    This method provides the image asociated to the cell in order to avoid a complicated to read method
     
     - parameter section: The desired section
     - parameter row: The desired row
     
     - returns: If the row is valid it should return a UIImage. nil otherwise
    */
    func iconForCellAtIndexPath(section : Int, row : Int) -> UIImage!{
        var image : UIImage
        
        if section == 1{
            image = UIImage(named: "logout")!
        }
        else{
            switch row{
            case 0:
                image =  UIImage(named: "pawCell")!
            case 1:
                image = UIImage(named: "activityRegistry")!
            case 2:
                image = UIImage(named: "payment")!
                
            default: return nil;
            }
        }
        
        image = image.imageWithRenderingMode(.AlwaysTemplate)
        return image
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        name.textColor = UIColor.whiteColor()
        self.animalEffectView.setImageArray(Constantes.animalArrayImages)
        
        
        user = Usuario(object:  PFUser.currentUser()!, imageLoaderObserver: {
            (usuario, completed) -> (Void) in
            dispatch_async(dispatch_get_main_queue()){
                if !self.changedImage && completed{
                    self.originalImage = usuario.image
                    self.imageView.image = self.originalImage
                }
            }
        })
        
        self.imageView.user = self.user
        name.text = user!.name
        self.originalImage = imageView.image
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "changeIcon"))
        imageView.userInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func changeIcon(){
        let controller = UIAlertController(title: NSLocalizedString("Attach image", comment: ""), message: NSLocalizedString("Select an image to set as profile picture", comment: ""), preferredStyle: .ActionSheet)
        
        controller.addAction(UIAlertAction(title: NSLocalizedString("Take picture", comment: ""), style: .Default, handler: {
            a in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                let controller = UIImagePickerController()
                controller.sourceType = UIImagePickerControllerSourceType.Camera
                controller.mediaTypes = [kUTTypeImage as String]
                controller.allowsEditing = true
                controller.delegate = self
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }))
        controller.addAction(UIAlertAction(title: NSLocalizedString("Select from library", comment: ""), style: .Default, handler: {
            a in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
                let controller = UIImagePickerController()
                controller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                controller.mediaTypes = [kUTTypeImage as String]
                controller.allowsEditing = true
                controller.delegate = self
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }))
        
        controller.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: {
            _ in
        }))
        
        presentViewController(controller, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        let originalmage = info[UIImagePickerControllerOriginalImage] as? UIImage
        var usingImage : UIImage?
        
        if let image = editedImage{
            usingImage = image
        }
        else if let image = originalmage{
            usingImage = image
        }
        
        if let image = usingImage{
            imageView.image = image
            changedImage = true
            user?.setNewProfileImage(image, callback: {
                (completed) -> Void in
                if(!completed){
                    let controller = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Something went wront, please try again later", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                    controller.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler: {
                        _ in
                    }))
                    self.presentViewController(controller, animated: true, completion: nil)
                }
            })
        }
        
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1{
            self.navigationController?.logoutUser()
        }
        else if indexPath.row == 0{
	     performSegueWithIdentifier("adoptedAnimals", sender: nil)
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
	 else if indexPath.row == 1{
            performSegueWithIdentifier("activity", sender: nil)
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
        else if(indexPath.row == 2){
            print("payment")
            performSegueWithIdentifier("cardsSegue", sender: nil)
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let nvc = segue.destinationViewController as? AdopedAnimalsViewController{
            nvc.user = self.user
        }
    }

}

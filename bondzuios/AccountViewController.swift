//
//  AccountViewController.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 9/28/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//

import UIKit
import Parse
import MobileCoreServices

class AccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
            
            switch indexPath.row{
            case 0:
                 cell.textLabel!.text = "Adoptions"
            case 1:
                 cell.textLabel!.text = "Activity"
            case 2:
                 cell.textLabel!.text = "Payment"
            default:
                cell.textLabel!.text = "Logout"
            }
            cell.accessoryType = .DisclosureIndicator
            return cell
        }
        else{
            let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
            cell.textLabel!.text = "Logout"
            return cell
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        name.text = (PFUser.currentUser()!["name"] as! String)
        self.originalImage = imageView.image
        if let photo = PFUser.currentUser()!["photo"] as? String{
            getImageInBackground(url: photo){
                image in
                if !self.changedImage{
                    self.imageView.image = image
                    self.originalImage = image
                    Imagenes.redondeaVista(self.imageView, radio: self.imageView.frame.width / 2)
                }
            }
        }
        else if let photo = PFUser.currentUser()!["photoFile"] as? PFFile{
            photo.getDataInBackgroundWithBlock({ (data, error) -> Void in
                guard error == nil && !self.changedImage, let imageData = data else{
                    return
                }
                
                let image = UIImage(data: imageData)
                self.imageView.image = image
                self.originalImage = image
                Imagenes.redondeaVista(self.imageView, radio: self.imageView.frame.width / 2)
            })
        }
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "changeIcon"))
        imageView.userInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeIcon(){
        let controller = UIAlertController(title: "Attach image", message: "Select an image to set as profile picture", preferredStyle: .ActionSheet)
        
        controller.addAction(UIAlertAction(title: "Take picture", style: .Default, handler: {
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
        controller.addAction(UIAlertAction(title: "Select from library", style: .Default, handler: {
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
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: {
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
        
        if let image = editedImage{
            self.imageView.image = image
            changedImage = true
        }
        else if let image = originalmage{
            imageView.image = image
            changedImage = true
        }
        
        Imagenes.redondeaVista(imageView, radio: imageView.frame.width / 2)
        
        let file = PFFile(data: UIImagePNGRepresentation(imageView.image!)!)
        let user = PFUser.currentUser()!
        user["photo" ] = NSNull()
        user["photoFile"] = file
        user.saveInBackgroundWithBlock { (salvado, error) -> Void in
            if error != nil{
                print("No se guardo \(error?.description)")
            }
            else{
                print("\(salvado) se guardo")
            }
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1{
            self.navigationController?.logoutUser()
        }
        else{
            performSegueWithIdentifier("adoptedAnimals", sender: nil)
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

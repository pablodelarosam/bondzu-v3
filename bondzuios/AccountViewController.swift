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
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationItem.title = NSLocalizedString("Account", comment: "")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
                 cell.textLabel!.text = NSLocalizedString("Adoptions", comment: "")
//no longer necessary
//            case 1:
//                 cell.textLabel!.text = NSLocalizedString("Activity", comment: "")
//            case 2:
//                 cell.textLabel!.text = NSLocalizedString("Payment", comment: "")
            default:
                cell.textLabel!.text = NSLocalizedString("Logout", comment: "")
            }
            
            
            cell.accessoryType = .disclosureIndicator
            cell.imageView?.tintColor = UIColor.white
            cell.imageView?.image = iconForCellAtIndexPath(indexPath.section, row: indexPath.row)
            
            return cell
        }
        else if indexPath.section == 1{
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel!.text = NSLocalizedString("Logout", comment: "")
            cell.backgroundColor = UIColor.clear
            cell.textLabel!.textColor = UIColor.white
            cell.imageView?.tintColor = UIColor.white
            cell.imageView?.image = iconForCellAtIndexPath(indexPath.section, row: indexPath.row)
            return cell
        }
        else{
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel!.text = NSLocalizedString("v3.2.2      b1594", comment: "")
            cell.backgroundColor = UIColor.clear
            cell.textLabel!.textColor = UIColor.white
            cell.imageView?.tintColor = UIColor.white
            cell.imageView?.image = iconForCellAtIndexPath(indexPath.section, row: indexPath.row)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        
        
        }
    }
    
    /**
    This method provides the image asociated to the cell in order to avoid a complicated to read method
     
     - parameter section: The desired section
     - parameter row: The desired row
     
     - returns: If the row is valid it should return a UIImage. nil otherwise
    */
    func iconForCellAtIndexPath(_ section : Int, row : Int) -> UIImage!{
        var image : UIImage
        
        if section == 1{
            image = UIImage(named: "logout")!
        }
        else{
            switch row{
            case 0:
                image =  UIImage(named: "pawCell")!
//            case 1:
//                image = UIImage(named: "activityRegistry")!
//            case 2:
//                image = UIImage(named: "payment")!
//                
            default: return nil;
            }
        }
        
        image = image.withRenderingMode(.alwaysTemplate)
        return image
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        name.textColor = UIColor.white
        self.animalEffectView.setImageArray(Constantes.animalArrayImages)
        
        
        user = Usuario(object:  PFUser.current()!, imageLoaderObserver: {
            (usuario, completed) -> (Void) in
            DispatchQueue.main.async{
                if !self.changedImage && completed{
                    self.originalImage = usuario.image
                    self.imageView.image = self.originalImage
                }
            }
        })
        
        self.imageView.user = self.user
        name.text = user!.name
        self.originalImage = imageView.image
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AccountViewController.changeIcon)))
        imageView.isUserInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func changeIcon(){
        let controller = UIAlertController(title: NSLocalizedString("Attach image", comment: ""), message: NSLocalizedString("Select an image to set as profile picture", comment: ""), preferredStyle: .actionSheet)
        
        controller.addAction(UIAlertAction(title: NSLocalizedString("Take picture", comment: ""), style: .default, handler: {
            a in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
                let controller = UIImagePickerController()
                controller.sourceType = UIImagePickerControllerSourceType.camera
                controller.mediaTypes = [kUTTypeImage as String]
                controller.allowsEditing = true
                controller.delegate = self
                self.present(controller, animated: true, completion: nil)
            }
        }))
        controller.addAction(UIAlertAction(title: NSLocalizedString("Select from library", comment: ""), style: .default, handler: {
            a in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
                let controller = UIImagePickerController()
                controller.sourceType = UIImagePickerControllerSourceType.photoLibrary
                controller.mediaTypes = [kUTTypeImage as String]
                controller.allowsEditing = true
                controller.delegate = self
                self.present(controller, animated: true, completion: nil)
            }
        }))
        
        controller.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: {
            _ in
        }))
        
        present(controller, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
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
                    let controller = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Something went wront, please try again later", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                    controller.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: {
                        _ in
                    }))
                    self.present(controller, animated: true, completion: nil)
                }
            })
        }
        
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            self.navigationController?.logoutUser()
        }
        else if indexPath.section == 2{
            //do nothing on the app's version text
            return
        }
        else if indexPath.row == 0{
	     performSegue(withIdentifier: "adoptedAnimals", sender: nil)
            tableView.deselectRow(at: indexPath, animated: false)
        }
	 else if indexPath.row == 1{
            performSegue(withIdentifier: "activity", sender: nil)
            tableView.deselectRow(at: indexPath, animated: false)
        }
        else if(indexPath.row == 2){
            print("payment")
            performSegue(withIdentifier: "cardsSegue", sender: nil)
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nvc = segue.destination as? AdopedAnimalsViewController{
            nvc.user = self.user
        }
    }

}

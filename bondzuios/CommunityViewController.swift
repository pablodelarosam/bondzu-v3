//
//  CommunityViewController.swift
//  bondzuios
//
//  Created by Ricardo Lopez on 12/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//

//NOTA: El codigo en reply es copiado de esta clase. Por tanto, si se realizan cambios a secciones como ver imagen, like etc se deberá modificar en ambos códigos. La herencia no es posible debido al cambio en el modelo de datos.
//TODO: Código homogeneo para funciones como like

import UIKit
import Parse
import MobileCoreServices

let defaultProfileImage = UIImage(named: "profile")

class CommunityViewController: UIViewController, CommunitEntryEvent, TextFieldWithImageButtonProtocol, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    //TODO Implementar un cache de una sola sesión para agilizar los datos
    var likesLoaded = false

    var animalID = "om2qMFKhpB"
    var loaded = false
    var objects : [CommunityViewDataManager]!
    var likes : [(Int , Bool)]!
    
    var gestureRecognizer : UITapGestureRecognizer?

    var toLoad = 0
    
    var hasImage = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: TextFieldWithImageButton!

    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = "Community"
        self.navigationController!.navigationBar.topItem!.rightBarButtonItem = nil
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        query()
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyBoardShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyBoardHide:", name: UIKeyboardWillHideNotification, object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !loaded{
            return 1
        }
        
        return objects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if !loaded{
            return tableView.dequeueReusableCellWithIdentifier("loading")!
        }
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("comment") as! CommunityEntryView
        
        cell.delegate = self
        
        if !objects[indexPath.row].imageLoaded{
            objects[indexPath.row].notifyOnReady.append((self.tableView,indexPath))
        }
        
        guard self.objects[indexPath.row].name != nil && self.objects[indexPath.row].message["message"] != nil else{
            
            let name = self.objects[indexPath.row].name == nil ? "" : self.objects[indexPath.row].name!
            let message = self.objects[indexPath.row].message["message"] == nil ? "" : self.objects[indexPath.row].message["message"] as! String
            
            cell.setInfo(self.objects[indexPath.row].message.objectId!, date: self.objects[indexPath.row].message.createdAt!, name: name, message: message , image: self.objects[indexPath.row].image , hasContentImage: self.objects[indexPath.row].message["photo_message"] != nil , hasLiked: false, likeCount: 0)
            
            objects[indexPath.row].notifyOnReady.append((tableView, indexPath))
            
            return cell
        }
        
        if likesLoaded{
            cell.setInfo(self.objects[indexPath.row].message.objectId!, date: self.objects[indexPath.row].message.createdAt!, name: self.objects[indexPath.row].name, message: self.objects[indexPath.row].message["message"] as! String, image: self.objects[indexPath.row].image , hasContentImage: self.objects[indexPath.row].message["photo_message"] != nil , hasLiked: likes[indexPath.row].1, likeCount: likes[indexPath.row].0)

        }
        else{
            cell.setInfo(self.objects[indexPath.row].message.objectId!, date: self.objects[indexPath.row].message.createdAt!, name: self.objects[indexPath.row].name, message: self.objects[indexPath.row].message["message"] as! String, image: self.objects[indexPath.row].image , hasContentImage: self.objects[indexPath.row].message["photo_message"] != nil , hasLiked: false, likeCount: 0)

        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    
    //TODO NO SIRVE CON ANIMAL V2 ACTUALIZAR NOMBRE
    func query(){
        let query = PFQuery(className: "Messages")
        query.orderByDescending("createdAt")
        query.whereKeyExists("message")
        query.whereKey("id_animal", equalTo: PFObject(withoutDataWithClassName: "Animal", objectId: animalID))
        query.findObjectsInBackgroundWithBlock(){
            array, error in
            
            guard error == nil else{
                dispatch_async(dispatch_get_main_queue()){
                    let controller = UIAlertController(title: "Cannot load community", message: "Please check your Internet conection and try again", preferredStyle: UIAlertControllerStyle.Alert)
                    controller.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: {
                        _ in
                        controller.dismissViewControllerAnimated(false){
                            self.tabBarController?.selectedIndex = 0
                        }
                    }))
                    self.presentViewController(controller, animated: true, completion: nil)
                }
                return
            }
            
            self.objects = [CommunityViewDataManager]()
            self.likes = [(Int,Bool)]()
            let messages = array as! [PFObject]
            
            //Workaround si no hay mensajes. No remover
            self.toLoad = array!.count + 1
            
            for i in messages{
                
                
                let o = CommunityViewDataManager(message: i, delegate: self.objectLoaded)

                self.objects.append(o)
                
            }
            
            //Workaround si no hay mensajes. No remover
            self.objectLoaded()
            
            dispatch_async(dispatch_get_main_queue()){
                self.getLikes()
            }
        }
        
    }

    func objectLoaded(){
        toLoad--
        
        if toLoad == 0{
            loaded = true
            tableView.reloadData()
        }
        
        
    }
    
    
    //CALL ASYNC
    func getLikes(){
        let uid = PFUser.currentUser()?.objectId!
        for object in objects{
            var valor = (0,false)
            if let i = object.message["likesRelation"] as? [String]{
                valor.0 = i.count
                
                
                for ids in i{
                    if ids == uid{
                        valor.1 = true
                    }
                }
            }
            
            likes.append(valor)
        }
        
        self.likesLoaded = true
        
        dispatch_async(dispatch_get_main_queue()){
            self.tableView.reloadData()
        }
    }
    
    func imageSelected(messageId: String) {
        let i = FullImageViewController()
        i.background = captureScreen()
        self.parentViewController!.presentViewController(i, animated: true, completion: nil)
        
        for j in 0..<objects.count{
            if objects[j].message.objectId! == messageId{
                i.loadParseImage(objects[j].message["photo_message"] as! PFFile)
                break
            }
        }
        
    }
    
    func like(messageId : String, like : Bool){
        for i in 0..<objects.count{
            if objects[i].message.objectId! == messageId{
                likes[i] = (likes[i].0 + ( like ? 1 : -1 ) , like)
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: i, inSection: 0)], withRowAnimation: .Automatic)
                
                objects[i].message.fetchInBackgroundWithBlock({
                    m, error in
                    
                    func destroy(){
                        self.likes[i].0 += like ? -1 : 1
                        self.likes[i].1 = !self.likes[i].1
                        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: i, inSection: 0)], withRowAnimation: .Automatic)
                        
                        print("Imposible guardar like. Deshaciendo.")
                    }
                    
                    guard error == nil , let newMessage = m else{
                        destroy()
                        
                        return
                    }
                    
                    if let array = newMessage["likesRelation"] as? [String]{
                        if like{
                            if !array.contains(PFUser.currentUser()!.objectId!){
                                var newArray = array
                                newArray.append(PFUser.currentUser()!.objectId!)
                                self.objects[i].message["likesRelation"] = newArray
                                self.objects[i].message.saveInBackgroundWithBlock(){
                                    bool , error in
                                    guard error == nil && bool else{
                                        destroy()
                                        return
                                    }
                                    
                                    print("LIKE")
                                }
                            }
                        }
                        else{
                            if array.contains(PFUser.currentUser()!.objectId!){
                                
                                var newArray = array
                                
                                for i in 0..<newArray.count{
                                    if newArray[i] == PFUser.currentUser()!.objectId!{
                                        newArray.removeAtIndex(i)
                                        break
                                    }
                                }
                                
                                self.objects[i].message["likesRelation"] = newArray
                                self.objects[i].message.saveInBackgroundWithBlock(){
                                    bool , error in
                                    guard error == nil && bool else{
                                        destroy()
                                        return
                                    }
                                    
                                    print("UNLIKE")
                                }
                            }
                        }
                    }
                    else if like{
                        newMessage["likesRelation"] = [PFUser.currentUser()!.objectId!]
                        self.objects[i].message.saveInBackgroundWithBlock(){
                            bool , error in
                            guard error == nil && bool else{
                                destroy()
                                return
                            }
                            
                            print("LIKE")
                        }
                    }
                })
                
                break
            }
        }
    }
    
    func report(messageId : String){}
    
    func reply(messageId : String){
        for i in 0..<objects.count{
            if objects[i].message.objectId! == messageId{
                performSegueWithIdentifier("reply", sender: i)
                break
            }
        }
    }
    
    func pressedButton(){
        let controller = UIAlertController(title: "Attach image", message: "Select an image to attach to your comment", preferredStyle: .ActionSheet)
        
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
        if(hasImage){
            controller.addAction(UIAlertAction(title: "Delete image", style: .Destructive, handler: {
                a in
                self.textField.imageView.image = UIImage(named: "camera_icon")
                self.hasImage = false
            }))
        }
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            a in
        }))
        
        presentViewController(controller, animated: true, completion: nil)
    }
    
    func sendButtonPressed(){
        guard let text = textField.text.text   where  textField.text.text!.characters.count != 0 else{
            let controller = UIAlertController(title: "Empty message", message: "Your message should not be empty", preferredStyle: UIAlertControllerStyle.Alert)
            controller.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: {
                _ in
                controller.dismissViewControllerAnimated(false, completion: nil)
            }))
            self.presentViewController(controller, animated: true, completion: nil)
            return
        }
        
        
        //TODO ACTUALIZAR PARA ANIMAL V2
        let comment = PFObject(className: "Messages")
        
        
        let animalObject =  Animal(withoutDataWithObjectId: animalID)

        
        comment["id_animal"] = animalObject
        comment["message"] = text
        comment["id_user"] = PFUser.currentUser()!
        comment["likesRelation"] = [String]()
        
        if(hasImage){
            comment["photo_message"] = PFFile(name: "image.png", data: UIImagePNGRepresentation(textField.imageView.image!)!)
        }
        
        textField.userInteractionEnabled = false
        
        comment.saveInBackgroundWithBlock(){
            
            bool, error in
            
            self.textField.userInteractionEnabled = true
            
            guard error == nil && bool else{
                let controller = UIAlertController(title: "Error", message: "Please check your internet connection and try again later", preferredStyle: UIAlertControllerStyle.Alert)
                controller.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: {
                    _ in
                    controller.dismissViewControllerAnimated(false, completion: nil)
                }))
                self.presentViewController(controller, animated: true, completion: nil)
                return
            }
            
            self.textField.text.text = ""
            self.textField.imageView.image = UIImage(named: "camera_icon")
            self.likesLoaded = false
            self.hasImage = false
            self.query()
        }
        
    }
    
    func keyBoardShow(notification : NSNotification){
        
        
        if let info = notification.userInfo{
            if let frame = info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue{
                guard tabBarController != nil else{
                    print("AY NANITA")
                    return
                }
                self.view.frame.origin.y = 0 - frame.height + (self.tabBarController?.tabBar.frame.size.height)!
                gestureRecognizer = UITapGestureRecognizer(target: self, action: "dissmisKeyboard")
                tableView.addGestureRecognizer(gestureRecognizer!)
            }
        }
    }
    
    func keyBoardHide(notification : NSNotification){
        self.view.frame.origin.y = 0
        guard gestureRecognizer != nil else{
            return
        }
        tableView.removeGestureRecognizer(gestureRecognizer!)
    }
    
    func dissmisKeyboard(){
        self.textField.text.resignFirstResponder()
    }

    
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "reply"{
            
            let index = sender as! Int
            
            let vc = segue.destinationViewController as! ReplyCommunityViewController
            vc.message = objects[index]
            vc.like = likes[index]
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        let originalmage = info[UIImagePickerControllerOriginalImage] as? UIImage

        if let image = editedImage{
            self.textField.imageView.image = image
            hasImage = true
        }
        else if let image = originalmage{
            self.textField.imageView.image = image
            hasImage = true
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}











/*ALERTA. ESTAS EN OTRA CLASE */

class CommunityViewDataManager{
    
    var message : PFObject
    var loadReadyDelegate : ()->()
    
    
    var name : String!
    var image : UIImage? = defaultProfileImage
    var imageLoaded = false
    
    var notifyOnReady =  [(UITableView , NSIndexPath)]()
    
    
    init(message : PFObject,  delegate :  ()->()){
        self.message  = message
        
        loadReadyDelegate = delegate
        
        let user = message["id_user"] as! PFObject
        user.fetchInBackgroundWithBlock(){
            object, error in
            guard error == nil , let user = object else{
                return
            }
            
            self.name = user["name"] as! String
            self.loadReadyDelegate()
            
            for (tv , ip) in self.notifyOnReady{
                tv.reloadRowsAtIndexPaths([ip], withRowAnimation: UITableViewRowAnimation.None)
            }
            
            self.notifyOnReady.removeAll()
            
            getImageInBackground(url: user["photo"] as! String){
                image in
                self.image = image
                self.imageLoaded = true
                
                for (tv , ip) in self.notifyOnReady{
                    tv.reloadRowsAtIndexPaths([ip], withRowAnimation: UITableViewRowAnimation.None)
                }
                
                self.notifyOnReady.removeAll()
            }
            
        }
    }
    
}

/*ALERTA. ESTAS EN OTRA CLASE */
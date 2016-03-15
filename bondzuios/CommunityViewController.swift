//
//  CommunityViewController.swift
//  bondzuios
//
//  Created by Ricardo Lopez on 12/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//  Archivo localizado

import UIKit
import Parse
import MobileCoreServices

/// The default profile image that will appear on users without image
let defaultProfileImage = UIImage(named: "profile")

/// The class is provided to controll the view of community. To initialize this class an animalID should be passed before the view loads.
class CommunityViewController: UIViewController, CommunitEntryEvent, TextFieldWithImageButtonProtocol, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LoadMessageResult, CommunityTabHelperProtocol{

    /// A var telling if the likes where already loaded or not.
    var likesLoaded = false

    /// The last post date loaded. This variable is usefull for query new items.
    var date : NSDate? = nil
    
    /// The animal id whose comments are being displayed.
    var animalID = ""
    
    /// Tells if the view is fully loaded or not yet.
    var loaded = false
    
    /// Tells if the query is working rigth now
    var loading = false
    
    /// The messages that are being displayed. This object should be initialized by the query.
    var objects : [Message]!
    
    /// An array containing tuples telling how many likes does a message has and if the user has already liked it or not.
    var likes : [(Int , Bool)]!
    
    /// Dissmises the keyboard when required.
    var gestureRecognizer : UITapGestureRecognizer?
    
    /// This variable is used when the user is creating a new message. This boolean tells whether the user has attached an image or not
    var hasImage = false
    
    /// Tells how many messages has to be loaded before they are shown. A message is consider loaded when the user image is proccesed
    var toLoad = 0
    
    /// This is a helper that will manage situations such as likes, reports, and image displaying.
    let cm = CommunityTabHelper()
    
    /// The table that show the comments
    @IBOutlet weak var tableView: UITableView!
    
    /// The text field in which the user enters his messages.
    @IBOutlet weak var textField: TextFieldWithImageButton!

    /// This is a temporary location to add likes that where not created on the firs query.
    var likes_temp : [(Int , Bool)]!
    
    /// This is a temporary variable to store the messages while they are loaded in a second query.
    var objects_temp : [Message]!
   
    /// A var telling if the likes where already loaded or not in a new set.
    var likesLoaded_temp = false
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("Community", comment: "")
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
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !loaded{
            return 1
        }
        
        if objects.count == 0{
            return 1
        }
        
        return objects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if !loaded{
            return tableView.dequeueReusableCellWithIdentifier("loading")!
        }
        
        if objects.count == 0{
            return tableView.dequeueReusableCellWithIdentifier("noMessages")!
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("comment") as! CommunityEntryView
        
        cell.delegate = self
        
        if likesLoaded{
            cell.setInfo(self.objects[indexPath.row], date: self.objects[indexPath.row].date, name: self.objects[indexPath.row].user!.name, message: self.objects[indexPath.row].message, image: self.objects[indexPath.row].user!.image, hasContentImage: self.objects[indexPath.row].hasAttachedImage , hasLiked: likes[indexPath.row].1, likeCount: likes[indexPath.row].0, user: self.objects[indexPath.row].user)

        }
        else{
            cell.setInfo(self.objects[indexPath.row], date: self.objects[indexPath.row].date, name: self.objects[indexPath.row].user!.name, message: self.objects[indexPath.row].message, image: self.objects[indexPath.row].user!.image, hasContentImage: self.objects[indexPath.row].hasAttachedImage , hasLiked: false, likeCount: 0, user: self.objects[indexPath.row].user)
        }
        
        return cell
    }
    
    //TODO: To avoid bug, create the cell in storyboard or nib
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    /**
     This function should be called in one of the following situations:
     1. The class is initializing its values
     2. The class wants to get the last messages
     
     The second case will only happen if the *loaded* property is true.
     */
    func query(){
        
        if loading{
            return
        }
        
        self.loading = true
        
        let query = PFQuery(className: TableNames.Messages_table.rawValue)
        query.orderByDescending(TableMessagesColumnNames.Date.rawValue)
        query.whereKeyExists(TableMessagesColumnNames.Message.rawValue)
        query.whereKey(TableMessagesColumnNames.Animal.rawValue, equalTo: PFObject(withoutDataWithClassName: TableNames.Animal_table.rawValue, objectId: animalID))
        
        if let date = date{
            query.whereKey(TableMessagesColumnNames.Date.rawValue, greaterThan: date)
        }
        
        query.findObjectsInBackgroundWithBlock(){
            array, error in
            
            guard error == nil else{
                let controller = UIAlertController(title: NSLocalizedString("Cannot load community", comment: ""), message: NSLocalizedString("Please check your Internet conection and try again", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                controller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Cancel, handler: {
                    _ in
                    controller.dismissViewControllerAnimated(false){
                        self.tabBarController?.selectedIndex = 0
                    }
                }))
                self.presentViewController(controller, animated: true, completion: nil)
                
                return
            }
            
            if !self.loaded{
                self.objects = [Message]()
                self.likes = [(Int,Bool)]()
                
            }
            else{
                self.objects_temp = [Message]()
                self.likes_temp = [(Int,Bool)]()
            }
            
            let messages = array!
            self.toLoad = messages.count
            
            if messages.count > 0 {
                self.date = messages[0].createdAt
            }
            

            for i in messages{
                let o = Message(object: i, delegate: self)
                if self.loaded{
                    self.objects_temp.append(o)
                }
                else{
                    self.objects.append(o)
                }
            }
            
            
            if self.objects.count == 0 && !self.loaded{
                self.loaded = true
                self.tableView.reloadData()
            }
        
            self.getLikes()
            self.loading = false
        }
    }

    /**
     This method will do its work in background so you should not assume the likes will be loaded after calling this method.
     
     This method will load the likes determining wether is the original set of data or a new one.
     
     This method will also determine when finished if it should append the new data now or later.
     */
    func getLikes(){
        
        let loaded = self.likes_temp != nil
        
        if NSThread.isMainThread(){
            dispatch_async(Constantes.get_bondzu_queue(), { () -> Void in
                self.getLikes()
                return
            })
        }
        
        self.likesLoaded_temp = false
        
        let usuario = Usuario(object: PFUser.currentUser()!, imageLoaderObserver: nil)
        
        let array = loaded ?  self.objects_temp : self.objects
        
        for object in array{
            let valor = (object.likesCount(), object.userHasLiked(usuario))
            if loaded{
                self.likes_temp.append(valor)
            }
            else{
                self.likes.append(valor)
            }
        }
        
        if !loaded{
            self.likesLoaded = true
            dispatch_async(dispatch_get_main_queue()){
                self.tableView.reloadData()
            }
        }
        else{
            self.likesLoaded_temp = true
            if toLoad == 0{
                dispatch_async(dispatch_get_main_queue()){
                    self.mergeTemp()
                }
            }
        }
    }
    
    func imageSelected(message: Message) {
        cm.showImage(message, fromViewController: self)
    }
    
    func like(message : Message, like : Bool){
        cm.like(message, like: like, user: Usuario(object: PFUser.currentUser()!, imageLoaderObserver: nil), delegate: self)
    }
    
    func report(message : Message){
        cm.report(nil, message: message, fromViewController: self)
    }
    
    func reply(message : Message){
       performSegueWithIdentifier("reply", sender: message)
    }
    
    func pressedButton(){
        let controller = UIAlertController(title: NSLocalizedString("Attach image", comment: ""), message: NSLocalizedString("Select an image to attach to your comment", comment: ""), preferredStyle: .ActionSheet)
        
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
        if(hasImage){
            controller.addAction(UIAlertAction(title: NSLocalizedString("Delete image", comment: ""), style: .Destructive, handler: {
                a in
                self.textField.imageView.image = UIImage(named: "camera_icon")
                self.hasImage = false
            }))
        }
        
        controller.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: {
            a in
        }))
        
        presentViewController(controller, animated: true, completion: nil)
    }
    
    func sendButtonPressed(){
        guard let text = textField.text.text   where  textField.text.text!.characters.count != 0 else{
            let controller = UIAlertController(title: NSLocalizedString("Empty message", comment: ""), message: NSLocalizedString("Your message should not be empty", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
            controller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Cancel, handler: {
                _ in
                controller.dismissViewControllerAnimated(false, completion: nil)
            }))
            self.presentViewController(controller, animated: true, completion: nil)
            return
        }
        
        
        let comment = PFObject(className: TableNames.Messages_table.rawValue)
        
        
        let animalObject =  Animal(withoutDataWithObjectId: animalID)
        
        comment[TableMessagesColumnNames.Animal.rawValue] = animalObject
        comment[TableMessagesColumnNames.Message.rawValue] = text
        comment[TableMessagesColumnNames.User.rawValue] = PFUser.currentUser()!
        comment[TableMessagesColumnNames.LikesRelation.rawValue] = [String]()
        
        if(hasImage){
            comment[TableMessagesColumnNames.Photo.rawValue] = PFFile(name: "image.png", data: UIImagePNGRepresentation(textField.imageView.image!)!)
        }
        
        textField.userInteractionEnabled = false
        
        comment.saveInBackgroundWithBlock(){
            
            bool, error in
            
            self.textField.userInteractionEnabled = true
            
            guard error == nil && bool else{
                let controller = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Please check your Internet conection and try again", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                controller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Cancel, handler: {
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
        gestureRecognizer = nil
    }
    
    func dissmisKeyboard(){
        self.textField.text.resignFirstResponder()
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "reply"{
            
            let index = sender as! Message
            let vc = segue.destinationViewController as! ReplyCommunityViewController
            vc.message = index
            vc.like = (index.likesCount(), index.userHasLiked(Usuario(object: PFUser.currentUser()!, imageLoaderObserver: nil)))
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
    
    func UserImageDidFailedLoading(message: Message) {}
    
    func UserImageDidFinishLoading(message: Message) {
        
        guard loaded else{
            return
        }
        
        self.tableView.reloadRowsAtIndexPaths( [NSIndexPath(forItem: objects.indexOf(message)!, inSection: 0)], withRowAnimation: .Automatic)
    }
    
    func UserDidLoad(message : Message){
        toLoad--
        
        if toLoad == 0{
            if !self.loaded{
                loaded = true
                tableView.reloadData()
            }
            else{
                if self.likesLoaded_temp{
                    self.mergeTemp()
                }
            }
        }
    }
    
    func UserDidFailedLoading(message : Message){
        let index = objects.indexOf(message)!
        objects.removeAtIndex(index)
        toLoad--
        
        if toLoad == 0{
            loaded = true
            tableView.reloadData()
        }
    }
    
    func operationDidSucceded( message : Message, operation : CommunityOperation ){
        let index = objects.indexOf(message)!
        likes[index] = (message.likesCount(), message.userHasLiked(Usuario(object: PFUser.currentUser()!, imageLoaderObserver: nil)))
        self.tableView.reloadRowsAtIndexPaths( [ NSIndexPath(forItem: index, inSection: 0)], withRowAnimation: .Automatic)
    }
    
    func operationDidFailed( message : Message, operation : CommunityOperation  ){
        let controller = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Please check your Internet conection and try again", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
        controller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Cancel, handler: {
            _ in
            controller.dismissViewControllerAnimated(false, completion: nil)
        }))
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func mergeTemp(){
        
        let reload = self.objects.count == 0 ? true : false
        
        var indexPaths = [NSIndexPath]()
        var index = 0
        
        while index < self.objects_temp.count{
            indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
            self.objects.insert(objects_temp[index], atIndex: index)
            self.likes.insert(likes_temp[index], atIndex: index)
            index++
        }
        
        self.objects_temp = nil
        self.likes_temp = nil
        
        if !reload{
            self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
        }
        else{
            self.tableView.reloadData()
        }
        
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
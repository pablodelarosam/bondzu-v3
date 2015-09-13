//
//  ReplyCommunityViewController.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 9/9/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//

import UIKit
import Parse

class ReplyCommunityViewController: UIViewController, UITextFieldDelegate, CommunitEntryEvent, UITableViewDelegate, UITableViewDataSource  {
    
    //TODO Implementar un cache de una sola sesión para agilizar los datos
    var likesLoaded = false
    
    //Parent view controller responsability
    var message : CommunityViewDataManager!
    //Parent view controller responsability
    var like : (Int , Bool)!

    var comment : [CommunityViewDataManager]!
    
    var loaded = false
    var gestureRecognizer : UITapGestureRecognizer?
    var toLoad = 0
    
    var textFieldStartValue : CGFloat?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = "Reply"
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        textField.delegate = self
        query()
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyBoardShow:", name: UIKeyboardWillShowNotification, object: nil)
        //Workaround error al cargar por primera vez el teclado
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyBoardShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyBoardHide:", name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if section == 0{
            return 1
        }
        else{
            if !loaded{
                return 1
            }
            
            return comment.count
        }
       
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCellWithIdentifier("comment") as! CommunityEntryView
            cell.delegate = self
            cell.setInfo(message.message.objectId!, date: message.message.createdAt!, name: message.name, message:message.message["message"] as! String, image: message.image , hasContentImage: message.message["photo_message"] != nil , hasLiked: like.1 , likeCount: like.0)
            cell.replyButton.hidden = true
            return cell
        }
        
        else{
            
            if !loaded{
                return tableView.dequeueReusableCellWithIdentifier("loading")!
            }
            else{
                
                let cell = tableView.dequeueReusableCellWithIdentifier("reply") as! CommunityReplyEntryCellTableViewCell
                
                guard self.comment[indexPath.row].name != nil && self.comment[indexPath.row].message["message"] != nil else{
                    
                    let name = self.comment[indexPath.row].name == nil ? "" : self.comment[indexPath.row].name!
                    let message = self.comment[indexPath.row].message["message"] == nil ? "" : self.comment[indexPath.row].message["message"] as! String
                    
                    cell.setInfo(self.comment[indexPath.row].message.objectId!, date: self.comment[indexPath.row].message.createdAt!, name: name, message: message , image: self.comment[indexPath.row].image)
                    
                    comment[indexPath.row].notifyOnReady.append((tableView, indexPath))
                    
                    return cell
                }
                
                cell.setInfo(comment[indexPath.row].message.objectId!, date: comment[indexPath.row].message.createdAt!, name: comment[indexPath.row].name, message: comment[indexPath.row].message["message"] as! String, image: comment[indexPath.row].image)
                
                if !comment[indexPath.row].imageLoaded{
                    comment[indexPath.row].notifyOnReady.append((tableView, indexPath))
                }
                return cell
            }
            

        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 75
        }
        else{
            return 50
        }
    }
    
    
    func query(){
        
        let query = PFQuery(className: "Comment")
        query.orderByAscending("createdAt")
        query.whereKeyExists("message")
        
        query.whereKey("parent", equalTo: message.message)
        query.findObjectsInBackgroundWithBlock(){
            array, error in
            
            guard error == nil else{
                dispatch_async(dispatch_get_main_queue()){
                    let controller = UIAlertController(title: "Cannot load community replies", message: "Please check your Internet conection and try again", preferredStyle: UIAlertControllerStyle.Alert)
                    controller.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: {
                        _ in
                        self.navigationController?.popViewControllerAnimated(true)
                        controller.dismissViewControllerAnimated(false){
                            navigationController?.popViewControllerAnimated(true)
                        }
                    }))
                    self.presentViewController(controller, animated: true, completion: nil)
                }
                return
            }
            
            self.comment = [CommunityViewDataManager]()
            let messages = array as! [PFObject]
            
            //Workaround si no hay mensajes. No remover
            self.toLoad = array!.count + 1
            
            for i in messages{
                
                
                let o = CommunityViewDataManager(message: i, delegate: self.objectLoaded)
                
                self.comment.append(o)
                
            }
            
            //Workaround si no hay mensajes. No remover
            self.objectLoaded()
        }
        
    }
    
    func objectLoaded(){
        toLoad--
        
        if toLoad == 0{
            loaded = true
            tableView.reloadData()
        }
    }
    
    
    func imageSelected(messageId: String) {
        let i = FullImageViewController()
        i.background = captureScreen()
        i.loadParseImage(message.message["photo_message"] as! PFFile)
        self.parentViewController!.presentViewController(i, animated: true, completion: nil)
    }
    
    func like(messageId : String, like : Bool){
        
        (self.like.0 + ( like ? 1 : -1 ) , like)
        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
        
        message.message.fetchInBackgroundWithBlock({
            m, error in
            
            func destroy(){
                self.like.0 += like ? -1 : 1
                self.like.1 = !self.like.1
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
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
                        self.message.message["likesRelation"] = newArray
                        self.message.message.saveInBackgroundWithBlock(){
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
                        
                        self.message.message["likesRelation"] = newArray
                        self.message.message.saveInBackgroundWithBlock(){
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
                self.message.message.saveInBackgroundWithBlock(){
                    bool , error in
                    guard error == nil && bool else{
                        destroy()
                        return
                    }
                    
                    print("LIKE")
                }
            }
        })
    }
    
    
    func report(messageId : String){}
    
    func reply(messageId : String){
        print("INVALID CALL FROM REPLY TO REPLY")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        guard let text = textField.text   where  textField.text!.characters.count != 0 else{
            let controller = UIAlertController(title: "Empty message", message: "Your reply should not be empty", preferredStyle: UIAlertControllerStyle.Alert)
            controller.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: {
                _ in
                controller.dismissViewControllerAnimated(false, completion: nil)
            }))
            self.presentViewController(controller, animated: true, completion: nil)
            return true
        }
        
        let reply = PFObject(className: "Comment")
        reply["parent"] = message.message
        reply["message"] = text
        reply["id_user"] = PFUser.currentUser()!
        textField.userInteractionEnabled = false
        
        reply.saveInBackgroundWithBlock(){
            
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
            
            self.query()
            self.textField.text = ""
        }
        
        return true
    }
    
    
    
    func keyBoardShow(notification : NSNotification){
        
        
        if let info = notification.userInfo{
            if let frame = info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue{
    
                if textFieldStartValue == nil{
                    textFieldStartValue = textField.frame.origin.y
                }
                
                self.textField.frame.origin.y = self.view.frame.height - frame.height - textField.frame.height
                gestureRecognizer = UITapGestureRecognizer(target: self, action: "dissmisKeyboard")
                tableView.addGestureRecognizer(gestureRecognizer!)
            }
        }
    }
    
    func keyBoardHide(notification : NSNotification){
        self.textField.frame.origin.y = textFieldStartValue!
        
        textFieldStartValue = nil
        
        guard gestureRecognizer != nil else{
            return
        }
        tableView.removeGestureRecognizer(gestureRecognizer!)
    }
    
    func dissmisKeyboard(){
        self.textField.resignFirstResponder()
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}





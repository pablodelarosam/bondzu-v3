//
//  ReplyCommunityViewController.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 9/9/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//  Archiv Localizado

import UIKit
import Parse

class ReplyCommunityViewController: UIViewController, UITextFieldDelegate, CommunitEntryEvent, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, CommunityTabHelperProtocol, LoadReplyResult{
        
    //Parent view controller responsability
    var message : Message!
    //Parent view controller responsability
    var like : (Int , Bool)!

    var comment : [Reply]!
    
    var loaded = false
    var gestureRecognizer : UITapGestureRecognizer?
    
    var textFieldStartValue : CGFloat?

    var comminutyHelper = CommunityTabHelper()
    
    var toLoad = 0
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("Reply", comment: "")
        super.viewDidAppear(animated)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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
            cell.setInfo(message, date: message.date, name: message.user!.name, message: message.message, image: message.user!.image , hasContentImage: message.hasAttachedImage, hasLiked: like.1 , likeCount: like.0)
            cell.replyButton.hidden = true
            return cell
        }
        
        else{
            
            if !loaded{
                return tableView.dequeueReusableCellWithIdentifier("loading")!
            }
            else{
                
                let cell = tableView.dequeueReusableCellWithIdentifier("reply") as! CommunityReplyEntryCellTableViewCell
            
                cell.setInfo(comment[indexPath.row], date: comment[indexPath.row].date, name: comment[indexPath.row].user!.name, message: comment[indexPath.row].message, image: comment[indexPath.row].user!.image)
    
                return cell
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 90
        }
        else{
            return 60
        }
    }
    
    func query(){
        
        let query = PFQuery(className: TableNames.Reply_table.rawValue)
        query.orderByAscending(TableReplyColumnNames.Date.rawValue)
        query.whereKeyExists(TableReplyColumnNames.Message.rawValue)
        
        query.whereKey(TableReplyColumnNames.ParentMessage.rawValue, equalTo: message.originalObject)
        query.findObjectsInBackgroundWithBlock(){
            array, error in
            
            guard error == nil else{
                dispatch_async(dispatch_get_main_queue()){
                    let controller = UIAlertController(title: NSLocalizedString("Cannot load community", comment: ""), message: NSLocalizedString("Please check your Internet conection and try again", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                    controller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Cancel, handler: {
                        _ in
                        self.navigationController?.popViewControllerAnimated(true)
                        controller.dismissViewControllerAnimated(false){
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                    }))
                    self.presentViewController(controller, animated: true, completion: nil)
                }
                return
            }
            
            self.comment = [Reply]()
            let messages = array!
            
            self.toLoad = messages.count
            
            for i in messages{
                let o = Reply(object: i, delegate: self)
                self.comment.append(o)
            }
            
            if messages.count == 0{
                self.loaded = true
                self.tableView.reloadData()
            }
            
        }
        
    }
    
    
    func imageSelected(message: Message) {
        comminutyHelper.showImage(message, fromViewController: self)
    }
    
    func like(message : Message, like : Bool){
        comminutyHelper.like(message, like: like, user: Usuario(object: PFUser.currentUser()!, imageLoaderObserver: nil), delegate: self)
    }
    
    func report(message : Message){
        comminutyHelper.report(nil, message: message, fromViewController: self)
    }
    
    func reply(message : Message){
        print("INVALID CALL FROM REPLY TO REPLY")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        guard let text = textField.text   where  textField.text!.characters.count != 0 else{
            let controller = UIAlertController(title: NSLocalizedString("Empty message", comment: ""), message: NSLocalizedString("Your message should not be empty", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
            controller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Cancel, handler: {
                _ in
                controller.dismissViewControllerAnimated(false, completion: nil)
            }))
            self.presentViewController(controller, animated: true, completion: nil)
            return true
        }
        
        let reply = PFObject(className: TableNames.Reply_table.rawValue)
        reply[TableReplyColumnNames.ParentMessage.rawValue] = message.originalObject
        reply[TableReplyColumnNames.Message.rawValue] = text
        reply[TableReplyColumnNames.User.rawValue] = PFUser.currentUser()!
        textField.userInteractionEnabled = false
        
        reply.saveInBackgroundWithBlock(){
            
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
        
        guard textFieldStartValue != nil else{
            return
        }
        
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
    
    func operationDidFailed(message: Message, operation: CommunityOperation) {
        
    }
    
    func operationDidSucceded(message: Message, operation: CommunityOperation) {
        
        like = (message.likesCount(), message.userHasLiked(Usuario(object: PFUser.currentUser()!, imageLoaderObserver: nil)))
        self.tableView.reloadRowsAtIndexPaths([ NSIndexPath(forItem: 0, inSection: 0) ], withRowAnimation: .Automatic)
    
    }
    
    func UserDidLoad( reply : Reply ){
        
        toLoad--
        if toLoad == 0{
            self.loaded = true
            self.tableView.reloadData()
        }
    }
    
    func UserDidFailedLoading( reply : Reply ){
        
        let index = self.comment.indexOf(reply)!
        self.comment.removeAtIndex(index)
        
        toLoad--
        if toLoad == 0{
            self.loaded = true
            self.tableView.reloadData()
        }
    }
    
    func UserImageDidFailedLoading(reply: Reply) {}
    
    func UserImageDidFinishLoading(reply: Reply) {
        
        let index = comment.indexOf(reply)!
        self.tableView.reloadRowsAtIndexPaths([ NSIndexPath(forItem: index, inSection: 1) ], withRowAnimation: .Automatic)
        
    }
}
//TODO AQUI Y EN COMMUNITY LAS PERSONAS CON NOMBRE LARGO PUEDEN DESPLAZAR LA TIME LABEL




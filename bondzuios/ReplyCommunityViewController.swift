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
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("Reply", comment: "")
        super.viewDidAppear(animated)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        textField.delegate = self
        query()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(ReplyCommunityViewController.keyBoardShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //Workaround error al cargar por primera vez el teclado
        NotificationCenter.default.addObserver(self, selector: #selector(ReplyCommunityViewController.keyBoardShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ReplyCommunityViewController.keyBoardHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "comment") as! CommunityEntryView
            cell.delegate = self
            cell.setInfo(message, date: message.date, name: message.user!.name, message: message.message, image: message.user!.image , hasContentImage: message.hasAttachedImage, hasLiked: like.1 , likeCount: like.0, user: message.user)
            cell.replyButton.isHidden = true
            return cell
        }
        
        else{
            
            if !loaded{
                return tableView.dequeueReusableCell(withIdentifier: "loading")!
            }
            else{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "reply") as! CommunityReplyEntryCellTableViewCell
            
                cell.setInfo(comment[indexPath.row], date: comment[indexPath.row].date, name: comment[indexPath.row].user!.name, message: comment[indexPath.row].message, image: comment[indexPath.row].user!.image)
    
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 90
        }
        else{
            return 60
        }
    }
    
    func query(){
        
        let query = PFQuery(className: TableNames.Reply_table.rawValue)
        query.order(byAscending: TableReplyColumnNames.Date.rawValue)
        query.whereKeyExists(TableReplyColumnNames.Message.rawValue)
        
        query.whereKey(TableReplyColumnNames.ParentMessage.rawValue, equalTo: message.originalObject)
        query.findObjectsInBackground(){
            array, error in
            
            guard error == nil else{
                DispatchQueue.main.async{
                    let controller = UIAlertController(title: NSLocalizedString("Cannot load community", comment: ""), message: NSLocalizedString("Please check your Internet conection and try again", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                    controller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: {
                        _ in
                        self.navigationController?.popViewController(animated: true)
                        controller.dismiss(animated: false){
                            self.navigationController?.popViewController(animated: true)
                        }
                    }))
                    self.present(controller, animated: true, completion: nil)
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
    
    func imageSelected(_ message: Message) {
        comminutyHelper.showImage(message, fromViewController: self)
    }
    
    func like(_ message : Message, like : Bool){
        comminutyHelper.like(message, like: like, user: Usuario(object: PFUser.current()!, imageLoaderObserver: nil), delegate: self)
    }
    
    func report(_ message : Message){
        comminutyHelper.report(nil, message: message, fromViewController: self)
    }
    
    func reply(_ message : Message){
        print("INVALID CALL FROM REPLY TO REPLY")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        guard let text = textField.text,  textField.text!.characters.count != 0 else{
            let controller = UIAlertController(title: NSLocalizedString("Empty message", comment: ""), message: NSLocalizedString("Your message should not be empty", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            controller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: {
                _ in
                controller.dismiss(animated: false, completion: nil)
            }))
            self.present(controller, animated: true, completion: nil)
            return true
        }
        
        let reply = PFObject(className: TableNames.Reply_table.rawValue)
        reply[TableReplyColumnNames.ParentMessage.rawValue] = message.originalObject
        reply[TableReplyColumnNames.Message.rawValue] = text
        reply[TableReplyColumnNames.User.rawValue] = PFUser.current()!
        textField.isUserInteractionEnabled = false
        
        reply.saveInBackground(){
            
            bool, error in
            
            self.textField.isUserInteractionEnabled = true

            guard error == nil && bool else{
                let controller = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Please check your Internet conection and try again", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                controller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: {
                    _ in
                    controller.dismiss(animated: false, completion: nil)
                }))
                self.present(controller, animated: true, completion: nil)
                return
            }
            
            self.query()
            self.textField.text = ""
        }
        
        return true
    }
    
    func keyBoardShow(_ notification : Notification){
        
        
        if let info = notification.userInfo{
            if let frame = (info[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue{
    
                if textFieldStartValue == nil{
                    textFieldStartValue = textField.frame.origin.y
                }
                
                self.textField.frame.origin.y = self.view.frame.height - frame.height - textField.frame.height
                gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReplyCommunityViewController.dissmisKeyboard))
                tableView.addGestureRecognizer(gestureRecognizer!)
            }
        }
    }
    
    func keyBoardHide(_ notification : Notification){
        
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
        NotificationCenter.default.removeObserver(self)
    }
    
    func operationDidFailed(_ message: Message, operation: CommunityOperation) {
        
    }
    
    func operationDidSucceded(_ message: Message, operation: CommunityOperation) {
        
        like = (message.likesCount(), message.userHasLiked(Usuario(object: PFUser.current()!, imageLoaderObserver: nil)))
        self.tableView.reloadRows(at: [ IndexPath(item: 0, section: 0) ], with: .automatic)
    
    }
    
    func UserDidLoad( _ reply : Reply ){
        
        toLoad -= 1
        if toLoad == 0{
            self.loaded = true
            self.tableView.reloadData()
        }
    }
    
    func UserDidFailedLoading( _ reply : Reply ){
        
        let index = self.comment.index(of: reply)!
        self.comment.remove(at: index)
        
        toLoad -= 1
        if toLoad == 0{
            self.loaded = true
            self.tableView.reloadData()
        }
    }
    
    func UserImageDidFailedLoading(_ reply: Reply) {}
    
    func UserImageDidFinishLoading(_ reply: Reply) {
        
        let index = comment.index(of: reply)!
        self.tableView.reloadRows(at: [ IndexPath(item: index, section: 1) ], with: .automatic)
        
    }
}
//TODO AQUI Y EN COMMUNITY LAS PERSONAS CON NOMBRE LARGO PUEDEN DESPLAZAR LA TIME LABEL




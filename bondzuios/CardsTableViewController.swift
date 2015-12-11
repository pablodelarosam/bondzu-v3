//
//  CardsTableViewController.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 08/10/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//  Archivo Localizado


import UIKit
import Parse

class CardsTableViewController: UITableViewController {
    
    var cards = [Card]();
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationItem.title = NSLocalizedString("Payment", comment: "")
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl?.beginRefreshing()
        self.tableView.setContentOffset(CGPoint(x: 0,y: self.tableView.contentOffset.y - self.refreshControl!.frame.size.height), animated: true)
        self.getCards()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if(self.refreshControl!.refreshing)
        {
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cards.count
    }
    
    func refresh(sender: AnyObject){
        self.getCards()
    }
    
    func getCards(){
        
        let user = Usuario(object: PFUser.currentUser()!, loadImage: false, imageLoaderObserver: nil)
        let id = user.stripeID
        
        let dic : [String: String] =
        [
            "customer_id" : id
        ]
        
        PFCloud.callFunctionInBackground(PFCloudFunctionNames.ListCards.rawValue, withParameters: dic) {
            (object , error) -> Void in
            if(error != nil)
            {
                dispatch_async(dispatch_get_main_queue()){
                    self.refreshControl?.endRefreshing()
                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Something went wront, please try again later", comment: ""), preferredStyle: .Alert);
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
            else
            {
                do {
                    if let data = object?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                        
                        let jsonDict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary
                        if let jsonDict = jsonDict {
                            // work with dictionary here
                            let key = "data";
                            print("data: \(jsonDict[key])")
                            self.cards.removeAll()
                            for item in jsonDict[key] as![Dictionary<String, AnyObject>] {
                                
                                let expyear = item["exp_year"]
                                let expmonth = item["exp_month"]
                                let last4 = item["last4"]
                                let id = item["id"]
                                let brand = item["brand"]
                                print("brand = \(brand!)")
                                
                                let card = Card(number: String(last4!), monthExp: String(expmonth!), yearExp: String(expyear!), id: String(id!), brand: String(brand!))
                                self.cards.append(card)
                            }
                            self.tableView.reloadData()
                            
                        } else {
                            // more error handling
                        }
                        
                    }
                } catch let error as NSError {
                    // error handling
                    print("error : \(error)")
                }
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cardCell", forIndexPath: indexPath)
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        //cell.label.adjustsFontSizeToFitWidth = true
        cell.textLabel?.text = "\(self.cards[indexPath.row].brand) " + NSLocalizedString("- Last 4 digits:", comment: "") + " \(self.cards[indexPath.row].number)";
        cell.detailTextLabel?.text = "\(self.cards[indexPath.row].monthExp) / \(self.cards[indexPath.row].yearExp)"
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let addAsFriendAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: NSLocalizedString("Delete", comment: ""), handler: {(action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            
            let addMenu = UIAlertController(title: nil, message: NSLocalizedString("Delete credit card:", comment: "") +  " \(self.cards[indexPath.row].number)", preferredStyle: .ActionSheet);
            
            let acceptAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction!) -> Void in
                self.removeCard(self.cards[indexPath.row], index: indexPath.row);
            })
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
            addMenu.addAction(acceptAction)
            addMenu.addAction(cancelAction)
            tableView.setEditing(false, animated: true)
            self.presentViewController(addMenu, animated: true, completion: nil)
        })
        
        addAsFriendAction.backgroundColor = UIColor.redColor()
        
        return [addAsFriendAction]
    }

    func removeCard(card: Card, index: Int){
        let user = Usuario(object: PFUser.currentUser()!, loadImage: false, imageLoaderObserver: nil)
        let cus_id = user.stripeID
        let card_id = card.id
        let dic : [String: String] =
        [
            "customer_id" : cus_id,
            "card_id" : card_id
        ]
        
        PFCloud.callFunctionInBackground(PFCloudFunctionNames.DeleteCard.rawValue, withParameters: dic) { (object, error) -> Void in
            if(error != nil)
            {
                let a = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("The credit card could not be removed", comment: ""), preferredStyle: .Alert)
                a.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
                self.presentViewController(a, animated: true, completion: nil)
            }
            else{
                self.cards.removeAtIndex(index)
                self.tableView.reloadData()
            }
        }
    }

}

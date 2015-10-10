//
//  CardsTableViewController.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 08/10/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//

import UIKit
import Parse

class CardsTableViewController: UITableViewController {
    
    var cards = [Card]();
    
    override func viewDidAppear(animated: Bool) {
        self.navigationItem.title = "Payment"
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.cards.count
    }
    
    func refresh(sender: AnyObject)
    {
        self.getCards()
    }
    
    func getCards()
    {
        
        PFUser.currentUser()?.fetchInBackgroundWithBlock({ (object, error) -> Void in
            let id = PFUser.currentUser()!["stripeId"] as! String!
            let dic : [String: String] =
            [
                "customer_id" : id
            ]
            PFCloud.callFunctionInBackground("listCards", withParameters: dic) { (object , error) -> Void in
                if(error != nil)
                {
                    self.refreshControl?.endRefreshing()
                    let alert = UIAlertController(title: "Error", message: "Something went wront, please try again later", preferredStyle: .Alert);
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                else
                {
                    print("object \(object!)")
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
                                    
                                    let card = Card();
                                    card.monthExp = String(expmonth!);
                                    card.yearExp = String(expyear!);
                                    card.number = String(last4!);
                                    card.id = String(id!);
                                    card.brand = String(brand!);
                                    
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
        })
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cardCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = "\(self.cards[indexPath.row].brand) - Last 4 digits: \(self.cards[indexPath.row].number!)";
        cell.detailTextLabel?.text = "\(self.cards[indexPath.row].monthExp!) / \(self.cards[indexPath.row].yearExp!)"
        // Configure the cell...

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let addAsFriendAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler: {(action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            
            let addMenu = UIAlertController(title: nil, message: "Delete credit card: \(self.cards[indexPath.row].number)", preferredStyle: .ActionSheet);
            
            let acceptAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction!) -> Void in
                self.removeCard(self.cards[indexPath.row], index: indexPath.row);
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            addMenu.addAction(acceptAction)
            addMenu.addAction(cancelAction)
            tableView.setEditing(false, animated: true)
            self.presentViewController(addMenu, animated: true, completion: nil)
        })
        
        addAsFriendAction.backgroundColor = UIColor.redColor()
        
        return [addAsFriendAction]
    }

    func removeCard(card: Card, index: Int)
    {
        let cus_id = PFUser.currentUser()!["stripeId"] as! String!
        let card_id = card.id
        let dic : [String: String] =
        [
            "customer_id" : cus_id,
            "card_id" : card_id
        ]
        
        PFCloud.callFunctionInBackground("deleteCard", withParameters: dic) { (object, error) -> Void in
            if(error != nil)
            {
                let a = UIAlertController(title: "Error", message: "The credit card could not be removed", preferredStyle: .Alert)
                a.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(a, animated: true, completion: nil)
            }else{
                self.cards.removeAtIndex(index)
                self.tableView.reloadData()
            }
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

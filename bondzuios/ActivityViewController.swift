//
//  ActivityViewController.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 10/1/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//

import UIKit
import Parse

class ActivityViewController: UITableViewController, TransactionLoadingDelegate{

    var activities = [Transaction]();
    var toLoad = 0
    var loaded = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Activity"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let q = PFQuery(className: "Transacciones")
        q.whereKey("userid", equalTo: PFUser.currentUser()!)
        q.findObjectsInBackgroundWithBlock { (arr, error) -> Void in
            if error == nil, let array = arr{
                self.toLoad = array.count + 1
                for t in array{
                    let transaction = Transaction(object: t as! PFObject)
                    self.activities.append(transaction!)
                    transaction?.delegate = self
                    
                }
                self.transaccionDidFinishLoading(nil)
            }
            else{
                print(error!)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loaded{
            return activities.count
        }
        return 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if !loaded{
            return tableView.dequeueReusableCellWithIdentifier("Loading")!
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("content") as! ActivityTableViewCell
        cell.load(activities[indexPath.row])
        return cell
    }
    
    func transaccionDidFinishLoading(t: Transaction?) {
        toLoad--;
        if toLoad == 0{
            loaded = true
            dispatch_async(dispatch_get_main_queue()){
                self.tableView.reloadData()
            }
        }
    }
    
    func transaccionDidFailLoading(t: Transaction?) {
        toLoad--;
        let index  = activities.indexOf(t!)!
        activities.removeAtIndex(index)
        if toLoad == 0{
            loaded = true
            dispatch_async(dispatch_get_main_queue()){
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
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



class ActivityTableViewCell : UITableViewCell{
    
    @IBOutlet weak var animalImage: UIImageView!
    
    @IBOutlet weak var itemName: UILabel!
    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var animalName: UILabel!
    
    @IBOutlet weak var price: UILabel!
    
    
    
    func load(transaction : Transaction){
        
        itemName.adjustsFontSizeToFitWidth = true
        animalName.adjustsFontSizeToFitWidth = true
        animalImage.image = transaction.animal.image
        itemName.text = transaction.itemDescrption
        price.text = "\(transaction.price)"
        animalName.text = transaction.animal.name
        
        let formater = NSDateFormatter()
        formater.dateStyle = NSDateFormatterStyle.ShortStyle
        formater.timeStyle = NSDateFormatterStyle.NoStyle
        date.text = formater.stringFromDate(transaction.date)
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        Imagenes.redondeaVista(animalImage, radio: animalImage.frame.width / 2)
    }
    
    
}

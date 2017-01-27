//
//  ActivityViewController.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 10/1/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//  Archivo localizado

import UIKit
import Parse

class ActivityViewController: UITableViewController, TransactionLoadingDelegate{

    var activities = [Transaction]();
    var toLoad = 0
    var loaded = false
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = NSLocalizedString("Activity", comment: "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let q = PFQuery(className: TableNames.Transactions_table.rawValue)
        q.whereKey(TableTransactionColumnNames.User.rawValue, equalTo: PFUser.current()!)
        q.findObjectsInBackground { (arr, error) -> Void in
            if error == nil, let array = arr{
                self.toLoad = array.count + 1
                for t in array{
                    let transaction = Transaction(object: t, delegate: self)
                    self.activities.append(transaction)
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
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loaded{
            return activities.count
        }
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !loaded{
            return tableView.dequeueReusableCell(withIdentifier: "Loading")!
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "content") as! ActivityTableViewCell
        cell.load(activities[indexPath.row])
        
        let cellIV = cell.animalImage as! CircledImageView
        
        if activities[indexPath.row].animal.hasLoadedPermission{
            cellIV.setBorderOfColor(activities[indexPath.row].animal.requiredPermission!.color, width: 3)
        }
        else{
            cellIV.setBorderOfColor(UIColor.white, width: 3)
            
            activities[indexPath.row].animal.addObserverToRequiredType({
                [weak self]
                _ in
                if let s = self{
                    s.tableView.reloadData()
                }
            })

            
        }
        
        
        return cell
    }
    
    func transaccionDidFinishLoading(_ t: Transaction?) {
        toLoad -= 1;
        if toLoad == 0{
            loaded = true
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        }
    }
    
    func transaccionDidFailLoading(_ t: Transaction?) {
        toLoad -= 1;
        let index  = activities.index(of: t!)!
        activities.remove(at: index)
        if toLoad == 0{
            loaded = true
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
}



class ActivityTableViewCell : UITableViewCell{
    
    @IBOutlet weak var animalImage: UIImageView!
    
    @IBOutlet weak var itemName: UILabel!
    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var animalName: UILabel!
    
    @IBOutlet weak var price: UILabel!
    

    func load(_ transaction : Transaction){
        
        itemName.adjustsFontSizeToFitWidth = true
        animalName.adjustsFontSizeToFitWidth = true
        animalImage.image = transaction.animal.image
        itemName.text = transaction.itemDescrption
        price.text = "\(transaction.price)"
        animalName.text = transaction.animal.name
        
        let formater = DateFormatter()
        formater.dateStyle = DateFormatter.Style.short
        formater.timeStyle = DateFormatter.Style.none
        date.text = formater.string(from: transaction.date as Date)
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
}


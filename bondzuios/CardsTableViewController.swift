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
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationItem.title = NSLocalizedString("Payment", comment: "")
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl?.addTarget(self, action: #selector(CardsTableViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        self.refreshControl?.beginRefreshing()
        self.tableView.setContentOffset(CGPoint(x: 0,y: self.tableView.contentOffset.y - self.refreshControl!.frame.size.height), animated: true)
        self.getCards()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if(self.refreshControl!.isRefreshing)
        {
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cards.count
    }
    
    func refresh(_ sender: AnyObject){
        self.getCards()
    }
    
    func getCards(){
        
        let user = Usuario(object: PFUser.current()!, loadImage: false, imageLoaderObserver: nil)
        let id = user.stripeID
        
        let dic : [String: String] =
        [
            "customer_id" : id
        ]
        
        PFCloud.callFunction(inBackground: PFCloudFunctionNames.ListCards.rawValue, withParameters: dic) {
            (object , error) -> Void in
            if(error != nil)
            {
                DispatchQueue.main.async{
                    self.refreshControl?.endRefreshing()
                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Something went wront, please try again later", comment: ""), preferredStyle: .alert);
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            else
            {
                do {
                     if let data = (object as! String).data(using: String.Encoding.utf8, allowLossyConversion: false)  {
                        
                        let jsonDict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? NSDictionary
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
                                
                                let card = Card(number: String(describing: last4!), monthExp: String(describing: expmonth!), yearExp: String(describing: expyear!), id: String(describing: id!), brand: String(describing: brand!))
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath)
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        //cell.label.adjustsFontSizeToFitWidth = true
        cell.textLabel?.text = "\(self.cards[indexPath.row].brand) " + NSLocalizedString("- Last 4 digits:", comment: "") + " \(self.cards[indexPath.row].number)";
        cell.detailTextLabel?.text = "\(self.cards[indexPath.row].monthExp) / \(self.cards[indexPath.row].yearExp)"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let addAsFriendAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: NSLocalizedString("Delete", comment: ""), handler: {(action: UITableViewRowAction!, indexPath: IndexPath!) -> Void in
            
            let addMenu = UIAlertController(title: nil, message: NSLocalizedString("Delete credit card:", comment: "") +  " \(self.cards[indexPath.row].number)", preferredStyle: .actionSheet);
            
            let acceptAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default, handler: {(action:UIAlertAction!) -> Void in
                self.removeCard(self.cards[indexPath.row], index: indexPath.row);
            })
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
            addMenu.addAction(acceptAction)
            addMenu.addAction(cancelAction)
            tableView.setEditing(false, animated: true)
            self.present(addMenu, animated: true, completion: nil)
        })
        
        addAsFriendAction.backgroundColor = UIColor.red
        
        return [addAsFriendAction]
    }

    func removeCard(_ card: Card, index: Int){
        let user = Usuario(object: PFUser.current()!, loadImage: false, imageLoaderObserver: nil)
        let cus_id = user.stripeID
        let card_id = card.id
        let dic : [String: String] =
        [
            "customer_id" : cus_id,
            "card_id" : card_id
        ]
        
        PFCloud.callFunction(inBackground: PFCloudFunctionNames.DeleteCard.rawValue, withParameters: dic) { (object, error) -> Void in
            if(error != nil)
            {
                let a = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("The credit card could not be removed", comment: ""), preferredStyle: .alert)
                a.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
                self.present(a, animated: true, completion: nil)
            }
            else{
                self.cards.remove(at: index)
                self.tableView.reloadData()
            }
        }
    }

}

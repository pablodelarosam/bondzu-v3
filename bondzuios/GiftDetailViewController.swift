//
//  GiftDetailViewController.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 17/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//  Archivo Localizado

import UIKit
import Parse
import Stripe

class GiftDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnDonate: UIButton!
    @IBOutlet weak var lblPrecio: UILabel!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var cards = [Card]();
    var producto: Producto!;
    var saveCardSwitchEnabled: Bool! = false;
    var alertController: UIAlertController!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.btnDonate.layer.cornerRadius = 10;
        self.btnDonate.layer.borderWidth = 0.5;
        self.btnDonate.layer.borderColor = UIColor.orangeColor().CGColor;
        self.image.image = self.producto.photo;
        self.lblName.text = self.producto.nombre;
        self.lblPrecio.text = "$ \(self.producto.precio1)";
        self.txtDescription.text = self.producto.infoAmount;
        self.txtDescription.font = UIFont.systemFontOfSize(18);
        self.navigationItem.title = self.producto.nombre
        let buttonBack = UIBarButtonItem(title: NSLocalizedString("Back", comment: ""), style: UIBarButtonItemStyle.Done, target: self, action: "backButtonClicked:");
        self.navigationItem.leftBarButtonItem = buttonBack
        self.navigationController?.navigationBar.barStyle = .Black;
        self.navigationController?.navigationBar.barTintColor = Constantes.COLOR_NARANJA_NAVBAR;
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor();
        self.activityIndicator.stopAnimating()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func donate(sender: UIButton){
        self.activityIndicator.startAnimating()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
            do{
                let user = Usuario(object: PFUser.currentUser()!, imageLoaderObserver: nil)
                let dic : [String: String] = [ "customer_id" : user.stripeID ]
                let object = try PFCloud.callFunction(PFCloudFunctionNames.ListCards.rawValue, withParameters: dic)
                
                guard let data = object.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) else{
                    throw Errors.GenericError
                }
                
                guard let jsonDict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary else{
                    throw Errors.GenericError
                }
                
                let key = "data";
                self.cards.removeAll()
                
                guard let items = jsonDict[key] as? [Dictionary<String, AnyObject>] else{
                    throw Errors.GenericError
                }
                
            
                if(items.count > 0){
                    for item in items{
                        
                        let expyear = item["exp_year"]
                        let expmonth = item["exp_month"]
                        let last4 = item["last4"]
                        let id = item["id"]
                        let brand = item["brand"]
                        
                    
                        let card = Card(number: String(last4!), monthExp: String(expmonth!), yearExp: String(expyear!), id: String(id!), brand: String(brand!))
                        self.cards.append(card)
                    }
                    
                    dispatch_async(dispatch_get_main_queue()){
                        
                        let vController = UIViewController()
                        var alertTableView: UITableView!;
                        var rect: CGRect!;
                        if(self.cards.count < 4)
                        {
                            rect = CGRect(x: 0, y: 0, width: 272, height: 100)
                        }
                        else if(self.cards.count < 6)
                        {
                            rect = CGRect(x: 0, y: 0, width: 272, height: 150)
                        }
                        else if(self.cards.count < 8)
                        {
                            rect = CGRect(x: 0, y: 0, width: 272, height: 200)
                        }
                        else
                        {
                            rect = CGRect(x: 0, y: 0, width: 272, height: 250)
                        }
                        
                        self.activityIndicator.stopAnimating()
                        
                        vController.preferredContentSize = CGSize(width: rect.width, height: rect.height)
                        alertTableView = UITableView(frame: rect)
                        alertTableView.delegate = self
                        alertTableView.dataSource = self
                        alertTableView.tableFooterView = UIView(frame: CGRect.zero)
                        alertTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
                        vController.view.addSubview(alertTableView)
                        vController.view.bringSubviewToFront(alertTableView)
                        vController.view.userInteractionEnabled = true
                        alertTableView.userInteractionEnabled = true
                        alertTableView.allowsSelection = true
                        
                        self.alertController = UIAlertController(title: NSLocalizedString("Cards", comment: ""), message: NSLocalizedString("Please select a card", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                        self.alertController.setValue(vController, forKey: "contentViewController")
                        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.Default, handler: nil)
                        let addAction = UIAlertAction(title: NSLocalizedString("Add a new card", comment: ""), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                            self.saveCardSwitchEnabled = true;
                            self.performSegueWithIdentifier("paySegue", sender: self)
                        })
                        
                        self.alertController.addAction(addAction)
                        self.alertController.addAction(cancelAction)
                        
                        self.presentViewController(self.alertController, animated: true, completion: nil)
                    }
                    
                }
                else{
                    dispatch_async(dispatch_get_main_queue()){
                        self.activityIndicator.stopAnimating()
                        self.saveCardSwitchEnabled = false;
                        self.performSegueWithIdentifier("paySegue", sender: self)
                        return;
                    }
                }
                
                
            }
            catch{
                dispatch_async(dispatch_get_main_queue()){
                    self.activityIndicator.stopAnimating()
                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Something went wront, please try again later", comment: ""), preferredStyle: .Alert);
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)

                }
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.alertController.dismissViewControllerAnimated(true, completion: nil)
        let cardSelected = self.cards[indexPath.row] as Card;
        let alert = UIAlertController(title: NSLocalizedString("Payment", comment: ""), message:String(format: NSLocalizedString("Please provide the CVC (3 numbers at the back of your card) of the card with last 4 digits: %@ in order to complete the payment", comment: ""), arguments: ["\(cardSelected.number)"])
            , preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = NSLocalizedString("cvc", comment: "")
            textField.keyboardType = UIKeyboardType.DecimalPad
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
            
            let txtFieldCvv = alert.textFields![0] as UITextField
            if(txtFieldCvv.text?.characters.count >= 3)
            {
                let payments = Payments()
                //make payment to existing customer
                payments.makePaymentToCurrentUserWithExistingCard(cardid: cardSelected.id, amount: String(self.producto.precio1), activityIndicator: self.activityIndicator, descripcion: self.producto.descripcion, controller: self, productId: self.producto.objectId, transDescription: "Gifts / Donations - \(self.producto.nombre) - Bondzu")
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.Default, handler: nil));
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(self.cards[indexPath.row].brand) - \(self.cards[indexPath.row].number)";
        return cell;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cards.count;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let payVC = segue.destinationViewController as? PagoViewController
        {
            payVC.producto = self.producto;
            payVC.switchEnabled = self.saveCardSwitchEnabled
        }
        
    }
    func backButtonClicked(sender: UIBarButtonItem){
        self.dismissViewControllerAnimated(true, completion: nil);
    }

}

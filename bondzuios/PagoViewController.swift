//
//  PagoViewController.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 19/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//

import UIKit
import Stripe
import Parse

class PagoViewController: UIViewController, STPPaymentCardTextFieldDelegate{

    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var nameView: UIView!
    
    @IBOutlet weak var paymentView: STPPaymentCardTextField!
    @IBOutlet weak var codeView: UIView!
    
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var txtAmount: UITextField!
    
    
    @IBOutlet weak var switchSaveCard: UISwitch!
    var buttonDone: UIBarButtonItem!;

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var producto: Producto!
    
    var txtCardValid = false;
    var switchEnabled: Bool!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonDone = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Done, target: self, action: "nextButtonClicked:");
        self.navigationItem.rightBarButtonItem = buttonDone
        self.txtAmount.text = "\(self.producto.precio1)";
        self.txtAmount.enabled = false;
        self.buttonDone.enabled = false;
        self.paymentView.delegate = self;
        self.activityIndicator.stopAnimating()
        self.switchSaveCard.setOn(switchEnabled, animated: true)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func nextButtonClicked(sender: AnyObject?)
    {
        print("Pay View Controller Next")
        self.view.endEditing(true)
        
        let payment = Payments()
        
        
        self.activityIndicator.startAnimating()
        let card = STPCard();
        card.number = self.paymentView.cardNumber;
        card.expMonth = self.paymentView.card!.expMonth;
        card.expYear = self.paymentView.card!.expYear;
        card.cvc = self.paymentView.card?.cvc;
        
        payment.makePaymentToCurrentUser(card: card, controller: self, amount: self.txtAmount.text!, activityIndicator: self.activityIndicator, saveCard: self.switchSaveCard.on, paymentView: self.paymentView, descripcion: self.producto!.descripcion)
        
        /*STPAPIClient.sharedClient().createTokenWithCard(card, completion: { (token, error) -> Void in
            if (error != nil)
            {
                print("ERROR enviando token");
                self.activityIndicator.stopAnimating()
                let a = UIAlertController(title: "Error", message: "The transaction could not be completed", preferredStyle: .Alert)
                a.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(a, animated: true, completion: nil)
            }
            else
            {
                if token != nil
                {
                    if(self.switchSaveCard.on)
                    {
                        print("Current user: \(PFUser.currentUser()!.email)");
                        let key = "stripeId"
                        
                        PFUser.currentUser()?.fetchInBackgroundWithBlock({ (object, error) -> Void in
                            if let cusId = PFUser.currentUser()![key] as! String!
                            {
                                self.saveCardOfCustomer(id: cusId, token: token!)
                            }
                        })
                        
                    }
                    else
                    {
                        self.createBackendChargeWithToken(token!)
                    }
                }
            }
        });*/
    }
    
    func saveCardOfCustomer(id id: String, token: STPToken)
    {
        
        let dic : [String: String] =
        [
            "customer_id" : id,
            "source" : token.tokenId
        ]
        
        PFCloud.callFunctionInBackground("createCard", withParameters: dic) { (result: AnyObject?, error: NSError?) in
            if(error == nil)
            {
                let card = STPCard();
                card.number = self.paymentView.cardNumber;
                card.expMonth = self.paymentView.card!.expMonth;
                card.expYear = self.paymentView.card!.expYear;
                card.cvc = self.paymentView.card?.cvc;
                
                STPAPIClient.sharedClient().createTokenWithCard(card, completion: { (token, error) -> Void in
                    if (error != nil)
                    {
                        print("ERROR enviando token");
                        self.activityIndicator.stopAnimating()
                        let a = UIAlertController(title: "Error", message: "The transaction could not be completed", preferredStyle: .Alert)
                        a.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                        self.presentViewController(a, animated: true, completion: nil)
                    }
                    else
                    {
                        if token != nil
                        {
                            
                            self.createBackendChargeWithToken(token!)
                        }
                    }
                });
            }
            else
            {
                let a = UIAlertController(title: "Error", message: "The transaction could not be completed", preferredStyle: .Alert)
                a.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(a, animated: true, completion: nil)
            }
        }
    }
    
    func createBackendChargeWithToken(token: STPToken)
    {
        print("Send token");
        
        if let doubleAmount = Double(self.txtAmount.text!) as Double!
        {
            let cantidadAPagarDouble = doubleAmount * 100
            let cantidadAPagar = Int(cantidadAPagarDouble)
            let cantidadEnCentavos = String(cantidadAPagar)
            let dic : [String: String] =
            [
                "amount" : cantidadEnCentavos,
                "currency" : "mxn",
                "source" : token.tokenId,
                "description": self.producto.descripcion
            ]
            
            PFCloud.callFunctionInBackground("createCharge", withParameters: dic) { (result: AnyObject?, error: NSError?) in
                let res = result as? NSObject
                print("result")
                print(res)
                self.activityIndicator.stopAnimating()
                
                if(error == nil)
                {
                    let a = UIAlertController(title: "Great!", message: "Thanks for your helpful donation", preferredStyle: .Alert)
                    a.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) -> Void in
                            self.navigationController?.popToRootViewControllerAnimated(true);
                    }))
                    self.presentViewController(a, animated: true, completion: nil)
                }else{
                    let a = UIAlertController(title: "Error", message: "The transaction could not be completed", preferredStyle: .Alert)
                    a.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                    self.presentViewController(a, animated: true, completion: nil)
                }
                
            }
        }
        else
        {
            self.activityIndicator.stopAnimating()
            print("Error")
            let a = UIAlertController(title: "Error", message: "The transaction could not be completed", preferredStyle: .Alert)
            a.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            presentViewController(a, animated: true, completion: nil)
        }
        
        /*
        PFCloud.callFunctionInBackground("createCharge", withParameters: ["amount":self.txtAmount.text, "currency":"mxn", "source": token, "description": "hola"] as [NSObject: AnyObject]? ) { (object, error) -> Void in
            if(error != nil)
            {
                print("error");
            }else{
                
            }
        }*/
    }
    
    @IBAction func txtNameChanged(sender: UITextField) {
        self.buttonDone.enabled = (!sender.text!.isEmpty && self.txtCardValid)
    }
    
    func paymentCardTextFieldDidChange(textField: STPPaymentCardTextField) {
        self.buttonDone.enabled = textField.valid && !self.txtName.text!.isEmpty;
        self.txtCardValid = textField.valid
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

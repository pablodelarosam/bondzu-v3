//
//  Payments.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 09/10/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//  Archivo localizado

/*
    Affected issue #25
*/

import Foundation
import Stripe
import Parse

class Payments
{
    func makePaymentToCurrentUserWithExistingCard(cardid cardid: String, amount: String, activityIndicator: UIActivityIndicatorView?, descripcion: String, controller: UIViewController, productId: String, transDescription: String)
    {
        if(activityIndicator != nil)
        {
            activityIndicator!.startAnimating()
        }
        PFUser.currentUser()?.fetchInBackgroundWithBlock({ (object, error) -> Void in
            if let cusId = PFUser.currentUser()![TableUserColumnNames.StripeID.rawValue] as! String!
            {
                self.createChargeToExistingCard(cusId: cusId, activityIndicator: activityIndicator, controller: controller, amount: amount, descripcion: descripcion, cardId: cardid, productId: productId, transDescription: transDescription)
            }
        })
    }
    
    func makePaymentToCurrentUser(card card: STPCard, controller: UIViewController, amount: String, activityIndicator: UIActivityIndicatorView?, saveCard: Bool, paymentView: STPPaymentCardTextField?, descripcion: String, productId: String, transDescription: String) -> Void
    {
        STPAPIClient.sharedClient().createTokenWithCard(card, completion: { (token, error) -> Void in
            if (error != nil)
            {
                print("ERROR enviando token");
                if(activityIndicator != nil)
                {
                    activityIndicator?.stopAnimating()
                }
                
                let a = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("The transaction could not be completed", comment: ""), preferredStyle: .Alert)
                a.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
                controller.presentViewController(a, animated: true, completion: nil)
            }
            else
            {
                if token != nil
                {
                    if(saveCard)
                    {
                        print("Current user: \(PFUser.currentUser()!.email)");
                        
                        PFUser.currentUser()?.fetchInBackgroundWithBlock({ (object, error) -> Void in
                            if let cusId = PFUser.currentUser()![TableUserColumnNames.StripeID.rawValue] as! String!
                            {
                                self.saveCardOfCustomer(id: cusId, token: token!, paymentView: paymentView!, activityIndicator: activityIndicator, controller: controller, amount: amount, descripcion: descripcion, productId: productId, transDescription: transDescription)
                            }
                        })
                        
                    }
                    else
                    {
                        self.createBackendChargeWithToken(token!, amount: amount, descripcion: descripcion, productId: productId, activityIndicator: activityIndicator, controller: controller, transDescription: transDescription)
                    }
                }
            }
        });
    }
    
    private func saveCardOfCustomer(id id: String, token: STPToken, paymentView: STPPaymentCardTextField, activityIndicator: UIActivityIndicatorView?, controller: UIViewController, amount: String, descripcion: String, productId: String, transDescription: String)
    {
        
        let dic : [String: String] =
        [
            "customer_id" : id,
            "source" : token.tokenId
        ]
        
        PFCloud.callFunctionInBackground(PFCloudFunctionNames.CreateCard.rawValue, withParameters: dic) { (result: AnyObject?, error: NSError?) in
            if(error == nil)
            {
                let card = STPCard();
                card.number = paymentView.cardNumber;
                card.expMonth = paymentView.card!.expMonth;
                card.expYear = paymentView.card!.expYear;
                card.cvc = paymentView.card?.cvc;
                
                STPAPIClient.sharedClient().createTokenWithCard(card, completion: { (token, error) -> Void in
                    if (error != nil)
                    {
                        print("ERROR enviando token");
                        
                        if(activityIndicator != nil){
                            activityIndicator!.stopAnimating()
                        }
                        
                        let a = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("The transaction could not be completed", comment: ""), preferredStyle: .Alert)
                        a.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
                        controller.presentViewController(a, animated: true, completion: nil)
                    }
                    else
                    {
                        if token != nil
                        {
                            self.createBackendChargeWithToken(token!, amount: amount, descripcion: descripcion, productId: productId, activityIndicator: activityIndicator, controller: controller, transDescription: transDescription)
                        }
                    }
                });
            }
            else
            {
                let a = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("The transaction could not be completed", comment: ""), preferredStyle: .Alert)
                a.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
                controller.presentViewController(a, animated: true, completion: nil)
            }
        }
    }
    
    private func createBackendChargeWithToken(token: STPToken, amount: String, descripcion: String, productId: String, activityIndicator: UIActivityIndicatorView?, controller: UIViewController, transDescription: String)
    {
        print("Send token");
        
        if let doubleAmount = Double(amount) as Double!
        {
            let cantidadAPagarDouble = doubleAmount * 100
            let cantidadAPagar = Int(cantidadAPagarDouble)
            let cantidadEnCentavos = String(cantidadAPagar)
            let dic : [String: String] =
            [
                "amount" : cantidadEnCentavos,
                "currency" : "mxn",
                "source" : token.tokenId,
                "description": descripcion
            ]
            
            PFCloud.callFunctionInBackground(PFCloudFunctionNames.CreateCharge.rawValue, withParameters: dic) { (result: AnyObject?, error: NSError?) in
                let res = result as? NSObject
                print("result")
                print(res)
                
                do {
                    if let data = result?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                        
                        let jsonDict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary
                        if let jsonDict = jsonDict {
                            // work with dictionary here
                            let key = "id";
                            print("transid: \(jsonDict[key])")
                            if let id = jsonDict[key] as? String{
                                self.saveTransactionInParse(transcationId: id, productid: productId, amount: amount, descripcion: transDescription)
                            }
                        }
                        
                    }
                } catch let error as NSError {
                    // error handling
                    print("error : \(error)")
                }
                
                if(activityIndicator != nil){
                    activityIndicator!.stopAnimating()
                }
                
                
                if(error == nil)
                {
                    let a = UIAlertController(title: NSLocalizedString("Great!", comment: ""), message: NSLocalizedString("Thanks for your helpful donation", comment: ""), preferredStyle: .Alert)
                    a.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: { (action: UIAlertAction) -> Void in
                        controller.navigationController?.popToRootViewControllerAnimated(true);
                    }))
                    controller.presentViewController(a, animated: true, completion: nil)
                }else{
                    let a = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("The transaction could not be completed", comment: ""), preferredStyle: .Alert)
                    a.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
                    controller.presentViewController(a, animated: true, completion: nil)
                }
                
            }
        }
        else
        {
            if(activityIndicator != nil){
                activityIndicator!.stopAnimating()
            }
            print("Error")
            let a = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("The transaction could not be completed", comment: ""), preferredStyle: .Alert)
            a.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
            controller.presentViewController(a, animated: true, completion: nil)
        }
        
    }
    
    private func createChargeToExistingCard(cusId cusId: String, activityIndicator: UIActivityIndicatorView?, controller: UIViewController, amount: String, descripcion: String, cardId: String, productId: String, transDescription: String)
    {
        if let doubleAmount = Double(amount) as Double!
        {
            let cantidadAPagarDouble = doubleAmount * 100
            let cantidadAPagar = Int(cantidadAPagarDouble)
            let cantidadEnCentavos = String(cantidadAPagar)
            let dic : [String: String] =
            [
                "customer_id": cusId,
                "card_id" : cardId,
                "amount" : cantidadEnCentavos,
                "currency" : "mxn",
                "description": descripcion
            ]
            
            PFCloud.callFunctionInBackground(PFCloudFunctionNames.CreateChargeExistingCard.rawValue, withParameters: dic) { (result: AnyObject?, error: NSError?) in
                let res = result as? NSObject
                print("result")
                print(res)
                
                do {
                    if let data = result?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                        
                        let jsonDict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary
                        if let jsonDict = jsonDict {
                            // work with dictionary here
                            let key = "id";
                            print("transid: \(jsonDict[key])")
                            if let id = jsonDict[key] as? String{
                                self.saveTransactionInParse(transcationId: id, productid: productId, amount: amount, descripcion: transDescription)
                            }
                        }
                        
                    }
                } catch let error as NSError {
                    // error handling
                    print("error : \(error)")
                }
                
                if(activityIndicator != nil){
                    activityIndicator!.stopAnimating()
                }
                
                if(error == nil)
                {
                    let a = UIAlertController(title: NSLocalizedString("Great!", comment: ""), message: NSLocalizedString("Thanks for your helpful donation", comment: ""), preferredStyle: .Alert)
                    a.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: { (action: UIAlertAction) -> Void in
                        controller.navigationController?.popToRootViewControllerAnimated(true);
                    }))
                    controller.presentViewController(a, animated: true, completion: nil)
                }else{
                    let a = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("The transaction could not be completed", comment: ""), preferredStyle: .Alert)
                    a.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .Default, handler: nil))
                    controller.presentViewController(a, animated: true, completion: nil)
                }
                
            }
        }
        else
        {
            if(activityIndicator != nil){
                activityIndicator!.stopAnimating()
            }
            print("Error")
            let a = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("The transaction could not be completed", comment: ""), preferredStyle: .Alert)
            a.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
            controller.presentViewController(a, animated: true, completion: nil)
        }
    }
    
    private func saveTransactionInParse(transcationId transactionId: String, productid: String, amount: String, descripcion: String)
    {
        let transaction  = PFObject(className: TableNames.Transactions_table.rawValue)
        transaction[TableTransactionColumnNames.User.rawValue] = PFUser.currentUser()
        transaction[TableTransactionColumnNames.Product.rawValue] = PFObject(withoutDataWithClassName: TableNames.Products.rawValue, objectId: productid)
        transaction[TableTransactionColumnNames.Transaction.rawValue] = transactionId
        transaction[TableTransactionColumnNames.Description.rawValue] = descripcion
        
        if let amountDouble = Double(amount) as Double?
        {
            let amountNumber = NSNumber(double: amountDouble)
            transaction[TableTransactionColumnNames.Price.rawValue] = amountNumber
        }
        
        transaction.saveInBackground()
    }
}
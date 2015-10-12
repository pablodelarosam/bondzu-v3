//
//  Payments.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 09/10/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//  Archivo localizado

import Foundation
import Stripe
import Parse

class Payments
{
    func makePaymentToCurrentUserWithExistingCard(cardid cardid: String, amount: String, activityIndicator: UIActivityIndicatorView?, descripcion: String, controller: UIViewController)
    {
        if(activityIndicator != nil)
        {
            activityIndicator!.startAnimating()
        }
        PFUser.currentUser()?.fetchInBackgroundWithBlock({ (object, error) -> Void in
            if let cusId = PFUser.currentUser()![TableUserColumnNames.StripeID.rawValue] as! String!
            {
                self.createChargeToExistingCard(cusId: cusId, activityIndicator: activityIndicator, controller: controller, amount: amount, descripcion: descripcion, cardId: cardid)
            }
        })
    }
    
    func makePaymentToCurrentUser(card card: STPCard, controller: UIViewController, amount: String, activityIndicator: UIActivityIndicatorView?, saveCard: Bool, paymentView: STPPaymentCardTextField?, descripcion: String) -> Void
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
                                self.saveCardOfCustomer(id: cusId, token: token!, paymentView: paymentView!, activityIndicator: activityIndicator, controller: controller, amount: amount, descripcion: descripcion)
                            }
                        })
                        
                    }
                    else
                    {
                        self.createBackendChargeWithToken(token!, amount: amount, descripcion: descripcion, activityIndicator: activityIndicator, controller: controller)
                    }
                }
            }
        });
    }
    
    private func saveCardOfCustomer(id id: String, token: STPToken, paymentView: STPPaymentCardTextField, activityIndicator: UIActivityIndicatorView?, controller: UIViewController, amount: String, descripcion: String)
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
                            self.createBackendChargeWithToken(token!, amount: amount, descripcion: descripcion, activityIndicator: activityIndicator, controller: controller)
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
    
    private func createBackendChargeWithToken(token: STPToken, amount: String, descripcion: String, activityIndicator: UIActivityIndicatorView?, controller: UIViewController)
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
            
            PFCloud.callFunctionInBackground("createCharge", withParameters: dic) { (result: AnyObject?, error: NSError?) in
                let res = result as? NSObject
                print("result")
                print(res)
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
        
        
        /*
        PFCloud.callFunctionInBackground("createCharge", withParameters: ["amount":self.txtAmount.text, "currency":"mxn", "source": token, "description": "hola"] as [NSObject: AnyObject]? ) { (object, error) -> Void in
        if(error != nil)
        {
        print("error");
        }else{
        
        }
        }*/
    }
    
    private func createChargeToExistingCard(cusId cusId: String, activityIndicator: UIActivityIndicatorView?, controller: UIViewController, amount: String, descripcion: String, cardId: String)
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
            
            PFCloud.callFunctionInBackground("createChargeExistingCard", withParameters: dic) { (result: AnyObject?, error: NSError?) in
                let res = result as? NSObject
                print("result")
                print(res)
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
}
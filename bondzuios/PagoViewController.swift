//
//  PagoViewController.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 19/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//

import UIKit
import Stripe

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

    var producto: Producto!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonDone = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Done, target: self, action: "nextButtonClicked:");
        self.navigationItem.rightBarButtonItem = buttonDone
        self.txtAmount.text = "\(self.producto.precio1)";
        self.txtAmount.enabled = false;
        self.buttonDone.enabled = false;
        self.paymentView.delegate = self;
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func nextButtonClicked(sender: AnyObject?)
    {
        print("Pay View Controller Next")
        let card = STPCard();
        card.number = self.paymentView.cardNumber;
        card.expMonth = self.paymentView.card!.expMonth;
        card.expYear = self.paymentView.card!.expYear;
        card.cvc = self.paymentView.card?.cvc;
        
        STPAPIClient.sharedClient().createTokenWithCard(card, completion: { (token, error) -> Void in
            if (error != nil)
            {
                print("ERROR");
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
    
    func createBackendChargeWithToken(token: STPToken)
    {
        print("Send token");
    }
    
    func paymentCardTextFieldDidChange(textField: STPPaymentCardTextField) {
        self.buttonDone.enabled = textField.valid;
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

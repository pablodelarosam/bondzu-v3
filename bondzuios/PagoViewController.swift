//
//  PagoViewController.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 19/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//  Archivo localizado

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
        self.buttonDone = UIBarButtonItem(title: NSLocalizedString("Next", comment: ""), style: UIBarButtonItemStyle.Done, target: self, action: "nextButtonClicked:");
        self.navigationItem.rightBarButtonItem = buttonDone
        self.txtAmount.text = "\(self.producto.precio1)";
        self.txtAmount.enabled = false;
        self.buttonDone.enabled = false;
        self.paymentView.delegate = self;
        self.activityIndicator.stopAnimating()
        self.switchSaveCard.setOn(switchEnabled, animated: true)
        // Do any additional setup after loading the view.
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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

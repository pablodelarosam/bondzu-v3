//
//  GiftDetailViewController.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 17/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//

import UIKit

class GiftDetailViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnDonate: UIButton!
    @IBOutlet weak var lblPrecio: UILabel!
    @IBOutlet weak var lblRecommend: UILabel!
    @IBOutlet weak var txtDescription: UITextView!
    var producto: Producto!;
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.btnDonate.layer.cornerRadius = 10;
        self.btnDonate.layer.borderWidth = 0.5;
        self.btnDonate.layer.borderColor = UIColor.orangeColor().CGColor;
        self.image.image = self.producto.photo;
        self.lblName.text = self.producto.nombre;
        self.lblPrecio.text = "\(self.producto.precio1)*";
        self.lblRecommend.text = "*Recommended ammount for this product";
        self.txtDescription.text = self.producto.infoAmount;
        self.txtDescription.font = UIFont.systemFontOfSize(18);
        self.navigationItem.title = self.producto.nombre
        let buttonBack = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Done, target: self, action: "backButtonClicked:");
        self.navigationItem.leftBarButtonItem = buttonBack
        self.navigationController?.navigationBar.barStyle = .Black;
        self.navigationController?.navigationBar.barTintColor = Constantes.COLOR_NARANJA_NAVBAR;
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func donate(sender: UIButton) {
        println("DONATE");
    }
    
    func backButtonClicked(sender: UIBarButtonItem)
    {
        self.dismissViewControllerAnimated(true, completion: nil);
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

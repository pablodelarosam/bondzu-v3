//
//  AboutUsViewController.swift
//  bondzuios
//
//  Created by Daniela Becerra on 13/04/16.
//  Copyright © 2016 Bondzu. All rights reserved.
//

import UIKit

class AboutUsViewController:  UIViewController, UITableViewDelegate, UITableViewDataSource{

     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 2
        }
        return 1;
        
    }
    
     func tableView(tableView: UITableView,cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            
            
            let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
            cell.textLabel!.textColor = UIColor.whiteColor()
            cell.backgroundColor = UIColor.clearColor()
            cell.tintColor = UIColor.redColor()
            
            switch indexPath.row{
            case 0:
                cell.textLabel!.text = NSLocalizedString("Historia", comment: "")
            case 1:
                cell.textLabel!.text = NSLocalizedString("Equipo", comment: "")
            default:
                cell.textLabel!.text = NSLocalizedString("Contáctanos", comment: "")
            }
            
            
            cell.accessoryType = .DisclosureIndicator
            cell.imageView?.tintColor = UIColor.whiteColor()
            cell.imageView?.image = iconForCellAtIndexPath(indexPath.section, row: indexPath.row)
            
            return cell
        }
        else{
            let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
            cell.textLabel!.text = NSLocalizedString("Contáctanos", comment: "")
            cell.backgroundColor = UIColor.clearColor()
            cell.textLabel!.textColor = UIColor.whiteColor()
            cell.imageView?.tintColor = UIColor.whiteColor()
            cell.imageView?.image = iconForCellAtIndexPath(indexPath.section, row: indexPath.row)
            return cell
        }
    }
    
    //cambiar iconos
    func iconForCellAtIndexPath(section : Int, row : Int) -> UIImage!{
        var image : UIImage
        
        if section == 1{
            image = UIImage(named: "contacto")!
        }
        else{
            switch row{
            case 0:
                image =  UIImage(named: "historia")!
            case 1:
                image = UIImage(named: "equipo")!
            default: return nil;
            }
        }
        
        image = image.imageWithRenderingMode(.AlwaysTemplate)
        return image
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    //I dont know if I need this
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//    }
    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }
//    
   
    //YA QUE PONGA LOS SEGUES, LO DESCOMENTO
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        if indexPath.section == 1{
//            //mandar mail
//        }
//        else if indexPath.row == 0{
//            performSegueWithIdentifier("historia", sender: nil)
//            tableView.deselectRowAtIndexPath(indexPath, animated: false)
//        }
//        else if indexPath.row == 1{
//            performSegueWithIdentifier("equipo", sender: nil)
//            tableView.deselectRowAtIndexPath(indexPath, animated: false)
//        }
//       
//    }

    //es para pasar valores al segue, creo que no lo necesito (5:00 am, no se)
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let nvc = segue.destinationViewController as? AdopedAnimalsViewController{
//            nvc.user = self.user
//        }
//    }


}

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
            //cell.imageView?.image = iconForCellAtIndexPath(indexPath.section, row: indexPath.row)
            
            return cell
        }
        else{
            let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
            cell.textLabel!.text = NSLocalizedString("Contáctanos", comment: "")
            cell.backgroundColor = UIColor.clearColor()
            cell.textLabel!.textColor = UIColor.whiteColor()
            cell.imageView?.tintColor = UIColor.whiteColor()
            //cell.imageView?.image = iconForCellAtIndexPath(indexPath.section, row: indexPath.row)
            return cell
        }
    }

}

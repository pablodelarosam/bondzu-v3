//
//  SpecialsViewController.swift
//  bondzuios
//
//  Created by Daniela Becerra on 13/04/16.
//  Copyright © 2016 Bondzu. All rights reserved.
//

import UIKit

class SpecialsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 6
        
    }
    
    func tableView(tableView: UITableView,cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
            //hacer con un arreglo
            let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
            cell.textLabel!.textColor = UIColor.whiteColor()
            cell.backgroundColor = UIColor.clearColor()
            cell.tintColor = UIColor.redColor()
            
            switch indexPath.row{
            case 0:
                cell.textLabel!.text = NSLocalizedString("Tienda", comment: "")
            case 1:
                cell.textLabel!.text = NSLocalizedString("Eventos", comment: "")
            case 2:
                cell.textLabel!.text = NSLocalizedString("Noticias", comment: "")
            case 3:
                cell.textLabel!.text = NSLocalizedString("Bondzu Girls", comment: "")
            case 4:
                cell.textLabel!.text = NSLocalizedString("Bondzu Games", comment: "")
            case 5:
                cell.textLabel!.text = NSLocalizedString("Wallpapers", comment: "")
            default:
                cell.textLabel!.text = NSLocalizedString("No debe aparecer", comment: "")
            }
            
            
            cell.accessoryType = .DisclosureIndicator
            cell.imageView?.tintColor = UIColor.whiteColor()
            //cell.imageView?.image = iconForCellAtIndexPath(indexPath.section, row: indexPath.row)
            
            return cell
        
    }
    
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            if indexPath.row == 0{
                performSegueWithIdentifier("tienda", sender: nil)
                tableView.deselectRowAtIndexPath(indexPath, animated: false)
            }

        }


}

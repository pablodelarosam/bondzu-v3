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
                cell.textLabel!.text = NSLocalizedString("Store", comment: "")
            case 1:
                cell.textLabel!.text = NSLocalizedString("Events", comment: "")
            case 2:
                cell.textLabel!.text = NSLocalizedString("News", comment: "")
            case 3:
                cell.textLabel!.text = "Bondzu Girls"
            case 4:
                cell.textLabel!.text = "Bondzu Games"
            case 5:
                cell.textLabel!.text = "Wallpapers"
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
            else {
                performSegueWithIdentifier("other", sender: nil)
                tableView.deselectRowAtIndexPath(indexPath, animated: false)
            }

        }


}

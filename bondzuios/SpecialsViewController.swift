//
//  SpecialsViewController.swift
//  bondzuios
//
//  Created by Daniela Becerra on 13/04/16.
//  Copyright © 2016 Bondzu. All rights reserved.
//

import UIKit

class SpecialsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let urlStrings = ["http://bondzu.com/tienda/", "http://bondzu.com/eventos/", "http://bondzu.com/bondzugirls/", "http://www.bondzu.com/Wallpapers/ios/#"]
    
    var row: Int = 0
    var nameOfNextView: String!
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 4
        
    }
    
    func tableView(tableView: UITableView,cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
            //hacer con un arreglo
            let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
            cell.textLabel!.textColor = UIColor.whiteColor()
            cell.backgroundColor = UIColor.clearColor()
            cell.tintColor = UIColor.redColor()
            let backView = UIView(frame: cell.frame)
            backView.backgroundColor = UIColor(hexString: "DD7A25") //naranja
            cell.selectedBackgroundView = backView
        
            switch indexPath.row{
            case 0:
                cell.textLabel!.text = NSLocalizedString("Store", comment: "")
            case 1:
                cell.textLabel!.text = NSLocalizedString("Events", comment: "")
            case 2:
                cell.textLabel!.text = "Bondzu Girls"
            case 3:
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
                //prepare
                self.row = indexPath.row
                let indexPath = tableView.indexPathForSelectedRow!
                let currentCell = tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
                nameOfNextView = currentCell.textLabel!.text
                //let's go
                performSegueWithIdentifier("tienda", sender: nil)
                tableView.deselectRowAtIndexPath(indexPath, animated: false)

        }

        override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
            if segue.identifier == "tienda" {
                let webVC = segue.destinationViewController as? StoreViewController
                webVC?.nameOfView = self.nameOfNextView
                webVC?.urlString = urlStrings[self.row]
            }
        }

}

extension Array {
    func contains<T where T : Equatable>(obj: T) -> Bool {
        return self.filter({$0 as? T == obj}).count > 0
    }
}

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
    
    let urlStrings = [NSLocalizedString("urlTienda", comment: ""), "http://bondzu.com/eventos/", NSLocalizedString("urlGirls", comment: ""), "http://www.bondzu.com/Wallpapers/ios/#"]
    
    var row: Int = 0
    var nameOfNextView: String!
    var wallpapersSelected = false
    var storeIsSelected = false
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 4
        
    }
    
    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            //hacer con un arreglo
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel!.textColor = UIColor.white
            cell.backgroundColor = UIColor.clear
            cell.tintColor = UIColor.red
            let backView = UIView(frame: cell.frame)
            backView.backgroundColor = UIColor(hexString: "DD7A25") //naranja
            cell.selectedBackgroundView = backView
        
            switch indexPath.row{
            case 0:
                cell.textLabel!.text = NSLocalizedString("Store", comment: "")
            case 1:
                cell.textLabel!.text = NSLocalizedString("Events", comment: "")
            case 2:
                cell.textLabel!.text = "Bondzù Girls"
            case 3:
                cell.textLabel!.text = "Wallpapers"
            default:
                cell.textLabel!.text = NSLocalizedString("No debe aparecer", comment: "")
            }
            
            
            cell.accessoryType = .disclosureIndicator
            cell.imageView?.tintColor = UIColor.white
            //cell.imageView?.image = iconForCellAtIndexPath(indexPath.section, row: indexPath.row)
            
            return cell
        
        }
    
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                //prepare
                self.row = indexPath.row
                let indexPath = tableView.indexPathForSelectedRow!
                let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
                nameOfNextView = currentCell.textLabel!.text
                //let's go
                performSegue(withIdentifier: "tienda", sender: nil)
                tableView.deselectRow(at: indexPath, animated: false)

        }

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "tienda" {
                let webVC = segue.destination as? StoreViewController
                webVC?.nameOfView = self.nameOfNextView
                webVC?.urlString = urlStrings[self.row]
//                if self.row == 3 {
//                    self.wallpapersSelected = true
//                }else{
//                    self.wallpapersSelected = false
//                }
                self.wallpapersSelected = self.row == 3 ? true : false
                self.storeIsSelected = self.row == 0 ? true : false
                webVC?.storeIsSelected =  self.storeIsSelected
                webVC?.wallpapersSelected = self.wallpapersSelected
            }
        }

}

//necessary to use the method contains in an array, no longer necessary.
extension Array {
    func contains<T>(_ obj: T) -> Bool where T : Equatable {
        return self.filter({$0 as? T == obj}).count > 0
    }
}

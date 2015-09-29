//
//  AdopedAnimalsViewController.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 9/29/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//

import UIKit
import Parse

class AdopedAnimalsViewController: UITableViewController {

    var loaded = false
    var animals : [PFObject]!
    var images : [UIImage?]!
    
    override func viewDidAppear(animated: Bool) {
        self.navigationItem.title = "Adopted Animals"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let relation = PFUser.currentUser()!["adoptersRelation"] as! PFRelation
        let query = relation.query()!
        query.findObjectsInBackgroundWithBlock { (animals, error) -> Void in
            if error != nil{
                print(error)
                return
            }
            self.images = Array<UIImage?>(count: (animals?.count)!, repeatedValue: UIImage())
            self.animals = animals as! [PFObject]
            
            for i in self.animals{
                let file = i["profilePhoto"] as! PFFile
                file.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    if data != nil && error == nil{
                        let img = UIImage(data: data!)
                        let index = self.animals.indexOf(i)
                        self.images[index!] = img
                        
                        dispatch_async(dispatch_get_main_queue()){
                            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index!, inSection: 0)], withRowAnimation: .Automatic)
                        }
                    }
                })
            }
            
            dispatch_async(dispatch_get_main_queue()){
                self.loaded = true
                self.tableView.reloadData()
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !loaded{
            return 1
        }
        return animals.count
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if !loaded{
            return tableView.dequeueReusableCellWithIdentifier("Loading")!
        }
    
        let cell = tableView.dequeueReusableCellWithIdentifier("content") as! AdoptedAnimalTableViewCell
        cell.animalImage.image = images[indexPath.row]
        Imagenes.redondeaVista(cell.animalImage, radio: cell.animalImage.frame.width / 2)
        cell.name.text = (animals[indexPath.row]["name"] as! String)
        cell.animalDescription.text = (animals[indexPath.row]["species"] as! String)
        
        
        
        return cell
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

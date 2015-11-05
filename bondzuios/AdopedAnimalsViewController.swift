//
//  AdopedAnimalsViewController.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 9/29/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//  Archivo Localizado

/*
    Archivo afectado issue #25
    viewDidLoad
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
*/

import UIKit
import Parse

class AdopedAnimalsViewController: UITableViewController {

    var loaded = false
    var animals : [PFObject]!
    var images : [UIImage?]!
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationItem.title = NSLocalizedString("Adopted Animals", comment: "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let relation = PFUser.currentUser()![TableUserColumnNames.AdoptedAnimalsRelation.rawValue] as! PFRelation
        let query = relation.query()!
        query.findObjectsInBackgroundWithBlock { (animals, error) -> Void in
            if error != nil{
                print(error)
                return
            }
            self.images = Array<UIImage?>(count: (animals?.count)!, repeatedValue: UIImage())
            self.animals = animals!
            
            for i in self.animals{
                let file = i[TableAnimalColumnNames.Photo.rawValue] as! PFFile
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
        cell.name.text = (animals[indexPath.row][TableAnimalColumnNames.Name.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! String)
        cell.animalDescription.text = (animals[indexPath.row][TableAnimalColumnNames.Species.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! String)
        return cell
    }
}


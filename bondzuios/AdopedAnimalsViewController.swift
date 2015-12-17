//
//  AdopedAnimalsViewController.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 9/29/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//  Archivo Localizado

import UIKit
import Parse

class AdopedAnimalsViewController: UITableViewController, AnimalV2LoadingProtocol {

    var loaded = false
    var animals : [AnimalV2]!
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationItem.title = NSLocalizedString("Adopted Animals", comment: "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Usuario(object: PFUser.currentUser()!, imageLoaderObserver: nil)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
            let (completed , animals) = user.getAdoptedAnimals(self)
            dispatch_async(dispatch_get_main_queue()){
                if completed{
                    self.animals = animals!
                }
                else{
                    self.animals = [AnimalV2]()
                    
                    let controller = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Something went wront, please try again later", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                    controller.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler: {
                        _ in
                    }))
                    self.presentViewController(controller, animated: true, completion: nil)
                    
                }
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
        cell.animalImage.image = animals[indexPath.row].image
        cell.name.text = animals[indexPath.row].name
        cell.animalDescription.text = animals[indexPath.row].animalDescription
        return cell
    }
    
    
    //MARK: AnimalV2LoadingProtocol implementation
    
    /**
    This method is an empty implementation. In case of error nothing will happen
    
    - parameter animal: The animal that have failed loading
    */
    func animalDidFailLoading(animal: AnimalV2) {}
    
    
    /**
     This method reload the cell asocioated with the animal that has just loaded.
     Imlplementation of AnimalV2LoadingProtocol
     
     - parameter animal: The animal that has just loaded
     */
    func animalDidFinishLoading(animal: AnimalV2) {
        dispatch_async(dispatch_get_main_queue()){
            //Workaround. Sometimes the elements are cached so this method is called even before the array is returned. Anyway even if the method does not process the event after the array is loaded reload table is called and fixes all not set images.
            if self.animals != nil{
                let index = self.animals.indexOf(animal)
                if let index = index{
                    self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
                }
            }
        }
    }
}


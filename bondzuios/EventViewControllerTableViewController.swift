//
//  EventViewControllerTableViewController.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 10/6/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//  Archivo localizado

import UIKit
import Parse
import EventKit

class EventViewControllerTableViewController: UITableViewController, EventLoadingDelegate, EventTableViewCellDelegate{

    var toLoad  = 0
    var loaded = false
    var animal : PFObject!
    var events = [Event]()
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = NSLocalizedString("Events", comment: "")
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let query = PFQuery(className: TableNames.Events_table.rawValue)
        query.whereKey(TableEventsColumnNames.Animal_ID.rawValue, equalTo: animal)
        query.findObjectsInBackgroundWithBlock { (array, error) -> Void in
            if error == nil, let eventsArray = array{
                for event in eventsArray{
                    let toAppendAnyTime = Event(object: event as! PFObject)
                    toAppendAnyTime.delegate = self
                }
            }
            else{
                print(error!)
                dispatch_async(dispatch_get_main_queue()){
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        }
        
        self.tableView.estimatedRowHeight = 73
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !loaded {return 1}
        return events.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if !loaded{
            return tableView.dequeueReusableCellWithIdentifier("loading")!
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("eventCell") as! EventTableViewCell
        let event = events[indexPath.row]
        cell.load(event.eventName, date: event.startDate, description: event.eventDescription, eventImage: event.eventImage, path: indexPath)
        cell.delegate = self
        return cell
    }
    
    func eventDidFailLoading(event : Event!){}
    
    func eventDidFinishLoading(event : Event!){
        dispatch_async(dispatch_get_main_queue()){
            self.events.append(event)
            if self.loaded{
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forItem: self.events.count - 1, inSection: 0)], withRowAnimation: .Automatic)
            }
            else{
                self.loaded = true
                self.tableView.reloadData()
            }
        }
    }
    
    func inputAccesoryPressedInCellWithIndexPath(indexPath: NSIndexPath) {
        let store = EKEventStore()
        
    
        
        store.requestAccessToEntityType(.Event) {
            (granted, error) -> Void in
            if error != nil || !granted{
                print("\(error) \(granted)")
                dispatch_async(dispatch_get_main_queue()){
                    let alert  = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Unable to store in calendar", comment: ""), preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
            else{
                let event = EKEvent(eventStore: store)
                event.title = self.events[indexPath.row].eventName
                event.startDate = self.events[indexPath.row].startDate
                event.endDate = self.events[indexPath.row].endDate
                event.calendar = store.defaultCalendarForNewEvents
                event.notes = self.events[indexPath.row].eventDescription
                do{
                    try store.saveEvent(event, span: EKSpan.ThisEvent, commit: true)
                    dispatch_async(dispatch_get_main_queue()){
                        let alert  = UIAlertController(title: NSLocalizedString("Done", comment: ""), message: NSLocalizedString("The event was successfully added to your calendar", comment: ""), preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
                catch{
                    print(error)
                    dispatch_async(dispatch_get_main_queue()){
                        let alert  = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Unable to store in calendar", comment: ""), preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
    }
}

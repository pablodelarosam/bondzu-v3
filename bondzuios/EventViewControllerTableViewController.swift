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
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = NSLocalizedString("Events", comment: "")
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let query = PFQuery(className: TableNames.Events_table.rawValue)
        query.whereKey(TableEventsColumnNames.Animal_ID.rawValue, equalTo: animal)
        query.whereKey(TableEventsColumnNames.End_Day.rawValue, greaterThan: Date())
        query.findObjectsInBackground { (array, error) -> Void in
            if error == nil, let eventsArray = array{
                for event in eventsArray{
                    let toAppendAnyTime = Event(object: event)
                    toAppendAnyTime.delegate = self
                }
            }
            else{
                print(error!)
                DispatchQueue.main.async{
                    self.navigationController?.popViewController(animated: true)
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !loaded {return 1}
        return events.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !loaded{
            return tableView.dequeueReusableCell(withIdentifier: "loading")!
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as! EventTableViewCell
        let event = events[indexPath.row]
        cell.load(event.eventName, date: event.startDate, description: event.eventDescription, eventImage: event.eventImage, path: indexPath)
        cell.delegate = self
        return cell
    }
    
    func eventDidFailLoading(_ event : Event!){}
    
    func eventDidFinishLoading(_ event : Event!){
        DispatchQueue.main.async{
            self.events.append(event)
            if self.loaded{
                self.tableView.insertRows(at: [IndexPath(item: self.events.count - 1, section: 0)], with: .automatic)
            }
            else{
                self.loaded = true
                self.tableView.reloadData()
            }
        }
    }
    
    func inputAccesoryPressedInCellWithIndexPath(_ indexPath: IndexPath) {
        let store = EKEventStore()
        
    
        
        store.requestAccess(to: .event) {
            (granted, error) -> Void in
            if error != nil || !granted{
                print("\(error) \(granted)")
                DispatchQueue.main.async{
                    let alert  = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Unable to store in calendar", comment: ""), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            else{
                let event = EKEvent(eventStore: store)
                event.title = self.events[indexPath.row].eventName
                event.startDate = self.events[indexPath.row].startDate as Date
                event.endDate = self.events[indexPath.row].endDate as Date
                event.calendar = store.defaultCalendarForNewEvents
                event.notes = self.events[indexPath.row].eventDescription
                do{
                    try store.save(event, span: EKSpan.thisEvent, commit: true)
                    DispatchQueue.main.async{
                        let alert  = UIAlertController(title: NSLocalizedString("Done", comment: ""), message: NSLocalizedString("The event was successfully added to your calendar", comment: ""), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                catch{
                    print(error)
                    DispatchQueue.main.async{
                        let alert  = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Unable to store in calendar", comment: ""), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}

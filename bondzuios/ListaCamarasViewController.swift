//
//  ListaCamarasViewController.swift
//  
//
//  Created by Luis Mariano Arobes on 10/08/15.
//  Archivo Localizado
//

import UIKit
import AVKit
import AVFoundation
import Parse

class ListaCamarasViewController: UITableViewController, UIPopoverPresentationControllerDelegate{

    var animalId: String!;
    var camaras = [Camera]();
    var player: AVPlayerViewController!
    let refreshcontrol = UIRefreshControl()    
    
    override func viewDidLoad() {
        //NSLocalizedString("CAMERAS", comment: "Choose a camera");
        self.title = NSLocalizedString("Cams", comment: "");
        //NSLocalizedString("DONE",comment: "Listo");
        let buttonDone = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: UIBarButtonItemStyle.Done, target: self, action: "doneButtonClicked:");
        self.navigationItem.rightBarButtonItem = buttonDone
        
        self.refreshcontrol.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshcontrol)
        self.refreshcontrol.beginRefreshing()
        self.tableView.setContentOffset(CGPoint(x: 0,y: self.tableView.contentOffset.y - self.refreshcontrol.frame.size.height), animated: true)
        
        getCameras()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.camaras.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("camaraCell") as UITableViewCell!
        var camara : Camera
        
        camara = self.camaras[indexPath.row]
        cell.textLabel?.text = camara.descripcion
        
        if(self.player != nil)
        {            
            if(camara.url == Utiles.urlOfAVPlayer(self.player.player))
            {
                cell.accessoryType = .Checkmark
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let camara = self.camaras[indexPath.row] as Camera;
        
        if let url = camara.url as NSURL!
        {
            if(url != Utiles.urlOfAVPlayer(self.player.player)){
                player.player?.pause()
                self.player.player = AVPlayer(URL: url)
                self.player.player?.closedCaptionDisplayEnabled = false;
                self.player.player?.play()
                self.dismissViewControllerAnimated(true, completion: nil)
                self.player = nil
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if(self.refreshcontrol.refreshing){
            self.refreshcontrol.endRefreshing()
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None;
    }
    
    
    func doneButtonClicked(sender: UIBarButtonItem){
        self.dismissViewControllerAnimated(true, completion: nil);
        player = nil
    }
    
    func refresh(sender: AnyObject){
        getCameras()
    }
    
    func getCameras(){
        let query = PFQuery(className: TableNames.Camera.rawValue);
        query.whereKey(TableCameraColumnNames.Animal.rawValue, equalTo: PFObject(withoutDataWithClassName: TableNames.Animal_table.rawValue, objectId: self.animalId))
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                // The find succeeded.
                self.camaras.removeAll(keepCapacity: true)
                // Do something with the found objects
                if let objects = objects{
                    for object in objects {
                        
                        let newCamera = Camera(object: object)
                        if(newCamera.funcionando!){
                            self.camaras.append(newCamera);
                        }
                    
                    }
                    self.tableView.reloadData()
                    if(self.refreshcontrol.refreshing){
                        self.refreshcontrol.endRefreshing()
                    }
                }
            }
            else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }

}

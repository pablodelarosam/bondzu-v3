//
//  ListaCamarasViewController.swift
//  
//
//  Created by Luis Mariano Arobes on 10/08/15.
//
//

import UIKit
import MediaPlayer
import Parse

class ListaCamarasViewController: UITableViewController, UIPopoverPresentationControllerDelegate{

    var animalId: String!;
    var camaras = [Camera]();
    var player: MPMoviePlayerController!
    let refreshcontrol = UIRefreshControl()    
    
    override func viewDidLoad() {
        //NSLocalizedString("CAMERAS", comment: "Choose a camera");
        self.title = "Cams";        
        //NSLocalizedString("DONE",comment: "Listo");
        let buttonDone = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "doneButtonClicked:");
        self.navigationItem.rightBarButtonItem = buttonDone
        
        self.refreshcontrol.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshcontrol)
        self.refreshcontrol.beginRefreshing()
        self.tableView.setContentOffset(CGPoint(x: 0,y: self.tableView.contentOffset.y - self.refreshcontrol.frame.size.height), animated: true)
        
        
        getCameras()
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
            if(camara.url == self.player.contentURL)
            {
                print("Esta viendo camara: \(camara.descripcion)")
                cell.accessoryType = .Checkmark
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let camara = self.camaras[indexPath.row] as Camera;
        print("Seleccionó camara: \(camara.descripcion)")
        
        if let url = camara.url as NSURL!
        {
            if(url != player.contentURL)
            {
                print(url)
                player.movieSourceType = MPMovieSourceType.Streaming
                player.contentURL = url;
                player.prepareToPlay()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            else
            {
                print("Se selecciono video que ya se esta reproduciendo")
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if(self.refreshcontrol.refreshing)
        {
            self.refreshcontrol.endRefreshing()
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None;
    }
    
    func doneButtonClicked(sender: UIBarButtonItem)
    {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func refresh(sender: AnyObject)
    {
        getCameras()
    }
    
    func getCameras()
    {
        let query = PFQuery(className: "Camera");
        query.whereKey("animal_id", equalTo: PFObject(withoutDataWithClassName: "Animal", objectId: self.animalId))
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                self.camaras.removeAll(keepCapacity: true)
                print("Successfully retrieved \(objects!.count) cameras.")
                // Do something with the found objects
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        
                        print(object.objectId)
                        let newCamera = Camera(_obj_id: object.objectId as String!,
                            _description: object.objectForKey("description") as! String,
                            _animalId: self.animalId,
                            _type: object.objectForKey("type") as! Int,
                            _animalName: object.objectForKey("animal_name") as! String,
                            _funcionando: object.objectForKey("funcionando") as! Bool,
                            _url: object.objectForKey("url") as? String)
                        
                        let url = object.objectForKey("url") as? String
                        print("url = \(url)")
                        print("desciption = \(newCamera.descripcion)");
                        print("url = \(newCamera.url)");
                        print("funcionando = \(newCamera.funcionando!)");
                        if(newCamera.funcionando!)
                        {
                            self.camaras.append(newCamera);
                        }
                    }
                    print("Cameras = \(self.camaras)")
                    self.tableView.reloadData()
                    if(self.refreshcontrol.refreshing)
                    {
                        self.refreshcontrol.endRefreshing()
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
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

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

@objc
protocol CameraChangingDelegate{
    func cameraWillChange(_ newCamera : Camera)
}


class ListaCamarasViewController: UITableViewController, UIPopoverPresentationControllerDelegate{

    var animalId: String!;
    var camaras = [Camera]();
    var player: AVPlayerViewController!
    let refreshcontrol = UIRefreshControl()    
    
    weak var delegate : CameraChangingDelegate?
    
    override func viewDidLoad() {
        //NSLocalizedString("CAMERAS", comment: "Choose a camera");
        self.title = NSLocalizedString("Cams", comment: "");
        //NSLocalizedString("DONE",comment: "Listo");
        let buttonDone = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: UIBarButtonItemStyle.done, target: self, action: #selector(ListaCamarasViewController.doneButtonClicked(_:)));
        self.navigationItem.rightBarButtonItem = buttonDone
        
        self.refreshcontrol.addTarget(self, action: #selector(ListaCamarasViewController.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshcontrol)
        self.refreshcontrol.beginRefreshing()
        self.tableView.setContentOffset(CGPoint(x: 0,y: self.tableView.contentOffset.y - self.refreshcontrol.frame.size.height), animated: true)
        
        getCameras()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.camaras.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "camaraCell") as UITableViewCell!
        var camara : Camera
        
        camara = self.camaras[indexPath.row]
        cell?.textLabel?.text = camara.descripcion
        
        if(self.player != nil)
        {            
            if(camara.url == Utiles.urlOfAVPlayer(self.player.player))
            {
                cell?.accessoryType = .checkmark
            }
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let camara = self.camaras[indexPath.row] as Camera;
        
        if let url = camara.url as URL!
        {
            if(url != Utiles.urlOfAVPlayer(self.player.player)){
                player.player?.pause()
                delegate?.cameraWillChange(camara)
                self.player.player = AVPlayer(url: url)
                self.player.player?.isClosedCaptionDisplayEnabled = false;
                self.player.player?.play()
                self.dismiss(animated: true, completion: nil)
                self.player = nil
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if(self.refreshcontrol.isRefreshing){
            self.refreshcontrol.endRefreshing()
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none;
    }
    
    
    func doneButtonClicked(_ sender: UIBarButtonItem){
        self.dismiss(animated: true, completion: nil);
        player = nil
    }
    
    func refresh(_ sender: AnyObject){
        getCameras()
    }
    
    func getCameras(){
        let query = PFQuery(className: TableNames.Camera.rawValue);
        
        query.whereKey(TableCameraColumnNames.Animal.rawValue, equalTo: PFObject(outDataWithClassName: TableNames.Animal_table.rawValue, objectId: self.animalId))
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                // The find succeeded.
                self.camaras.removeAll(keepingCapacity: true)
                // Do something with the found objects
                if let objects = objects{
                    for object in objects {
                        
                        let newCamera = Camera(object: object)
                        if(newCamera.funcionando!){
                            self.camaras.append(newCamera);
                        }
                    
                    }
                    self.tableView.reloadData()
                    if(self.refreshcontrol.isRefreshing){
                        self.refreshcontrol.endRefreshing()
                    }
                }
            }
            else {
                print("Error: \(error!) \(error!)")
            }
        }
    }

}

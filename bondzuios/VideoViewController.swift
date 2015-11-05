//
//  ViewController.swift
//  Bondzu
//
//  Created by Luis Mariano Arobes on 03/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//  Archivo localizado


/*
    affected issue #25
    getCameraAndSetup

*/

import UIKit
import AVKit
import AVFoundation
import Parse



class VideoViewController: AVPlayerViewController, UIPopoverPresentationControllerDelegate, NoCamerasDismissedProtocol{
    
    var url:NSURL!    
    var cameraButton: UIButton!
    let sizeCameraButton: CGFloat = 49
    var popover: UIPopoverPresentationController!
    var animalId: String!
    var backgroundImageNoCameras: UIImage!
    
    var dissmising = false
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    
    override func viewDidDisappear(animated: Bool) {
        player?.pause()
        if let p = popover{
            
            p.delegate = nil
            popover = nil
        }
        player = nil;
    }
    
    override func viewWillAppear(animated: Bool) {
        if !dissmising{
            player = AVPlayer()
            getFirstCameraAndSetup()
        }
    }
    
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        print(self.navigationItem)
        print(self.navigationController)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func doneButtonClick(notificacion: NSNotification)
    {
        
        self.navigationController?.popViewControllerAnimated(false);
    }
    
    func cameraButtonClicked(sender: AnyObject)
    {
        let popViewController: ListaCamarasViewController = self.storyboard!.instantiateViewControllerWithIdentifier("listaVideosPop") as! ListaCamarasViewController;
        popViewController.animalId = self.animalId                
        popViewController.player = self;
        let navController: UINavigationController = UINavigationController(rootViewController: popViewController)
        navController.modalPresentationStyle = UIModalPresentationStyle.Popover
        popViewController.modalPresentationStyle = .Popover
        self.popover = navController.popoverPresentationController as UIPopoverPresentationController!
        popViewController.preferredContentSize = CGSizeMake(200, 200)
        self.popover.delegate = self
        self.popover.sourceView = self.view;
        self.popover.sourceRect = self.cameraButton.frame        
        self.presentViewController(navController, animated: true, completion: nil)
        
        /*var popViewController: ListaCamarasViewController = self.storyboard!.instantiateViewControllerWithIdentifier("listaVideosPop") as! ListaCamarasViewController
        popViewController.modalPresentationStyle = .Popover
        popViewController.preferredContentSize = CGSizeMake(200, 200)
        
        let popover = popViewController.popoverPresentationController
        popover?.permittedArrowDirections = UIPopoverArrowDirection.Down;
        popover?.delegate = self
        popover?.sourceView = self.moviePlayerController.view
        popover?.sourceRect = self.cameraButton.frame
        self.moviePlayerController.presentViewController(popViewController, animated: true, completion: nil)*/
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func rotated()
    {
        let widthMoviePlayer = self.view.bounds.width;
        let heightMoviePlayer = self.view.bounds.height;
        self.cameraButton.frame = CGRectMake(widthMoviePlayer-self.sizeCameraButton, heightMoviePlayer-self.sizeCameraButton, self.sizeCameraButton, self.sizeCameraButton)
        if(self.popover != nil)
        {
            self.popover.sourceRect = self.cameraButton.frame
        }
    }
    
    //Obtiene la primera camara funcionando y la despliega
    func getFirstCameraAndSetup()
    {
        let query = PFQuery(className: TableNames.Camera.rawValue);
        query.whereKey(TableCameraColumnNames.Animal.rawValue, equalTo: PFObject(withoutDataWithClassName: TableNames.Animal_table.rawValue, objectId: self.animalId))
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                if(objects!.isEmpty)
                {
                    let query = PFQuery(className: TableNames.VideoCapsule_table.rawValue)
                    query.whereKey(TableVideoCapsuleNames.AnimalID.rawValue, equalTo: PFObject(withoutDataWithClassName: TableNames.Animal_table.rawValue, objectId: self.animalId))
                    query.findObjectsInBackgroundWithBlock({ (array, error) -> Void in
                        
                        guard error == nil, let videos = array  where videos.count > 0 else{
                            self.performSegueWithIdentifier("noCamerasSegue", sender: self)
                            return
                        }
                        let videoID = random() % videos.count
                        let capsule = Capsule(object: videos[videoID], delegate: nil)
                        dispatch_async(dispatch_get_main_queue()){
                            self.performSegueWithIdentifier("loadCapsule", sender: capsule)
                        }
                        return
                    })

                    return;
                }
                // Do something with the found objects
                if let objects = objects{
                    for object in objects {
                        
                        print(object.objectId)
                        let newCamera = Camera(_obj_id: object.objectId as String!,
                            _description: object.objectForKey(TableCameraColumnNames.Description.rawValue) as! String,
                            _animalId: self.animalId,
                            _type: object.objectForKey(TableCameraColumnNames.CameraType.rawValue) as! Int,
                            _animalName: object.objectForKey("animal_name") as! String,
                            _funcionando: object.objectForKey("funcionando") as! Bool,
                            _url: object.objectForKey(TableCameraColumnNames.PlayBackURL.rawValue) as? String)
                        
                        let url = object.objectForKey("url") as? String
                        if(newCamera.funcionando!)
                        {
                            self.url = NSURL(string: url!);
                            self.setup()
                            return
                        }
                    }
                }
                
                self.performSegueWithIdentifier("noCamerasSegue", sender: self)
                return;
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let viewController = segue.destinationViewController
        if let vc = viewController as? NoCamerasViewController
        {
            vc.backImage = self.backgroundImageNoCameras
            vc.dismissProtocol = self
        }
        else if segue.identifier == "loadCapsule"{
            
            let vc = viewController as!  VideoCapsulasViewController
            vc.requireToolBar(true)
            vc.capsule = sender as! Capsule
        }
    }
    
    func setup()
    {
        
        /*self.moviePlayerController = AVPlayerViewController();
        self.moviePlayerController.player = AVPlayer(URL: url);*/
        
        /*self.moviePlayerController.moviePlayer.fullscreen = true;
        self.moviePlayerController.moviePlayer.controlStyle = MPMovieControlStyle.Fullscreen;*/
        
        let sizeScreen = UIScreen.mainScreen().bounds;
        let widthMoviePlayer = sizeScreen.width;
        let heightMoviePlayer = sizeScreen.height;
        let image = UIImage(named: "camera") as UIImage!
        self.cameraButton  = UIButton(type: UIButtonType.Custom)
        self.cameraButton.setImage(image, forState: UIControlState.Normal)
        self.cameraButton.frame = CGRectMake(widthMoviePlayer-self.sizeCameraButton, heightMoviePlayer-self.sizeCameraButton, self.sizeCameraButton, self.sizeCameraButton)
        
        self.cameraButton.addTarget(self, action: "cameraButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)        
        
        //self.presentViewController(self.moviePlayerController, animated: false, completion: nil)
        /*self.moviePlayerController.view.addSubview(self.cameraButton);
        self.moviePlayerController.player?.play();
        self.moviePlayerController.player!.closedCaptionDisplayEnabled = false;*/
        
        
        //self.activityIndicator.stopAnimating()
        
        self.player = AVPlayer(URL: url);
        self.view.addSubview(self.cameraButton);
        self.player?.play();
        self.player?.closedCaptionDisplayEnabled = false;
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "doneButtonClick:", name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
    }
    
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        self.popover = nil
    }
    
    override func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {
        dissmising = true
        super.dismissViewControllerAnimated(true, completion: {
            _ in
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    deinit{
        print("Video View controller is been deallocated")
    }
}


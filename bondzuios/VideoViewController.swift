//
//  ViewController.swift
//  Bondzu
//
//  Created by Luis Mariano Arobes on 03/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//

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
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    
    override func viewDidDisappear(animated: Bool) {
        player?.pause()
        player = nil;
    }
    
    override func viewWillAppear(animated: Bool) {
        player = AVPlayer()
        getFirstCameraAndSetup()
    }
    
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(navigationController?.navigationBarHidden == false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func doneButtonClick(notificacion: NSNotification)
    {
        print("Termino video");
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
        print("ROTATED");
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
        let query = PFQuery(className: "Camera");
        query.whereKey("animal_id", equalTo: PFObject(withoutDataWithClassName: "Animal", objectId: self.animalId))
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                //print("Successfully retrieved \(objects!.count) cameras.")
                
                
                if(objects!.isEmpty)
                {
                    //self.url = NSURL(string: "http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8");
                    //self.setup()
                    self.performSegueWithIdentifier("noCamerasSegue", sender: self)
                    return;
                }
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
                        /*print("url = \(url)")
                        print("desciption = \(newCamera.descripcion)");
                        print("url = \(newCamera.url)");
                        print("funcionando = \(newCamera.funcionando!)");*/
                        if(newCamera.funcionando!)
                        {
                            self.url = NSURL(string: url!);
                            self.setup()
                            return
                        }
                    }
                }
                /*self.url = NSURL(string: "http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8");
                self.setup() //LLAMADA*/
                self.performSegueWithIdentifier("noCamerasSegue", sender: self)
                return;
            } else {
                // Log details of the failure
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
    
    deinit{
        print("Video View controller is been deallocated")
    }
}


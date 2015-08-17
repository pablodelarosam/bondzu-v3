//
//  ViewController.swift
//  Bondzu
//
//  Created by Luis Mariano Arobes on 03/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//

import UIKit
import MediaPlayer
import Parse

class VideoViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    
    //var moviePlayerController:MPMoviePlayerController!
    var moviePlayerController:MPMoviePlayerViewController!
    var url:NSURL!    
    var cameraButton: UIButton!
    let sizeCameraButton: CGFloat = 49
    var popover: UIPopoverPresentationController!
    var animalId: String!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.activityIndicator.startAnimating()
        getFirstCameraAndSetup()
    }
    
    override func viewDidAppear(animated: Bool) {
        println("View did appear");
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func doneButtonClick(notificacion: NSNotification)
    {
        println("Termino video");
        //self.dismissMoviePlayerViewControllerAnimated()
        self.navigationController?.popViewControllerAnimated(false);
    }
    
    func cameraButtonClicked(sender: AnyObject)
    {
        println("Camera clicked");
        
        var popViewController: ListaCamarasViewController = self.storyboard!.instantiateViewControllerWithIdentifier("listaVideosPop") as! ListaCamarasViewController;
        popViewController.animalId = self.animalId                
        popViewController.player = self.moviePlayerController.moviePlayer
        var navController: UINavigationController = UINavigationController(rootViewController: popViewController)
        navController.modalPresentationStyle = UIModalPresentationStyle.Popover
        popViewController.modalPresentationStyle = .Popover
        self.popover = navController.popoverPresentationController as UIPopoverPresentationController!
        popViewController.preferredContentSize = CGSizeMake(200, 200)
        self.popover.delegate = self
        self.popover.sourceView = self.moviePlayerController.view
        self.popover.sourceRect = self.cameraButton.frame        
        self.moviePlayerController.presentViewController(navController, animated: true, completion: nil)
        
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
        println("ROTATED");
        let widthMoviePlayer = self.moviePlayerController.view.bounds.width;
        let heightMoviePlayer = self.moviePlayerController.view.bounds.height;
        self.cameraButton.frame = CGRectMake(widthMoviePlayer-self.sizeCameraButton, heightMoviePlayer-self.sizeCameraButton, self.sizeCameraButton, self.sizeCameraButton)
        if(self.popover != nil)
        {
            self.popover.sourceRect = self.cameraButton.frame
        }
    }
    
    //Obtiene la primera camara funcionando y la despliega
    func getFirstCameraAndSetup()
    {
        var query = PFQuery(className: "Camera");
        query.whereKey("animal_id", equalTo: PFObject(withoutDataWithClassName: "Animal", objectId: self.animalId))
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                println("Successfully retrieved \(objects!.count) cameras.")
                // Do something with the found objects
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        
                        println(object.objectId)
                        var newCamera = Camera(_obj_id: object.objectId as String!,
                            _description: object.objectForKey("description") as! String,
                            _animalId: self.animalId,
                            _type: object.objectForKey("type") as! Int,
                            _animalName: object.objectForKey("animal_name") as! String,
                            _funcionando: object.objectForKey("funcionando") as! Bool,
                            _url: object.objectForKey("url") as? String)
                        
                        let url = object.objectForKey("url") as? String
                        println("url = \(url)")
                        println("desciption = \(newCamera.descripcion)");
                        println("url = \(newCamera.url)");
                        println("funcionando = \(newCamera.funcionando!)");
                        if(newCamera.funcionando!)
                        {
                            self.url = NSURL(string: url!);
                            self.setup()
                            return
                        }
                    }
                }
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }
    }

    func setup()
    {
        self.moviePlayerController = MPMoviePlayerViewController(contentURL: url);
        self.moviePlayerController.moviePlayer.fullscreen = true;
        self.moviePlayerController.moviePlayer.controlStyle = MPMovieControlStyle.Fullscreen;
        
        let widthMoviePlayer = self.moviePlayerController.view.bounds.width;
        let heightMoviePlayer = self.moviePlayerController.view.bounds.height;
        let image = UIImage(named: "camera") as UIImage!
        self.cameraButton  = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        self.cameraButton.setImage(image, forState: UIControlState.Normal)
        self.cameraButton.frame = CGRectMake(widthMoviePlayer-self.sizeCameraButton, heightMoviePlayer-self.sizeCameraButton, self.sizeCameraButton, self.sizeCameraButton)
        
        self.cameraButton.addTarget(self, action: "cameraButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.moviePlayerController.moviePlayer.view.addSubview(self.cameraButton);
        
        self.moviePlayerController.moviePlayer.prepareToPlay();
        
        self.presentMoviePlayerViewControllerAnimated(self.moviePlayerController)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "doneButtonClick:", name: MPMoviePlayerPlaybackDidFinishNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
        self.activityIndicator.stopAnimating()
    }
}


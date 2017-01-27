//
//  ViewController.swift
//  Bondzu
//
//  Created by Luis Mariano Arobes on 03/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//  Archivo localizado

import UIKit
import AVKit
import AVFoundation
import Parse



class VideoViewController: AVPlayerViewController, UIPopoverPresentationControllerDelegate, NoCamerasDismissedProtocol, CameraChangingDelegate{
    
    var user : Usuario!
    
    var url:URL!    
    var cameraButton: UIButton!
    let sizeCameraButton: CGFloat = 49
    var popover: UIPopoverPresentationController!
    var animalId: String!
    var backgroundImageNoCameras: UIImage!
    
    var camera : Camera?
    
    var dissmising = false
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    
    override func viewDidDisappear(_ animated: Bool) {
        camera?.stopWatchingVideo()
        player?.pause()
        
        
        if let p = popover{
            
            p.delegate = nil
            popover = nil
        }
        player = nil;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !dissmising{
            player = AVPlayer()
            getFirstCameraAndSetup()
        }
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
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
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func doneButtonClick(_ notificacion: Notification)
    {
        
        self.navigationController?.popViewController(animated: false);
    }
    
    func cameraButtonClicked(_ sender: AnyObject){
        let popViewController: ListaCamarasViewController = self.storyboard!.instantiateViewController(withIdentifier: "listaVideosPop") as! ListaCamarasViewController;
        popViewController.animalId = self.animalId                
        popViewController.player = self;
        let navController: UINavigationController = UINavigationController(rootViewController: popViewController)
        navController.modalPresentationStyle = UIModalPresentationStyle.popover
        popViewController.modalPresentationStyle = .popover
        popViewController.delegate = self
        self.popover = navController.popoverPresentationController as UIPopoverPresentationController!
        popViewController.preferredContentSize = CGSize(width: 200, height: 200)
        self.popover.delegate = self
        self.popover.sourceView = self.view;
        self.popover.sourceRect = self.cameraButton.frame        
        self.present(navController, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func rotated()
    {
        let widthMoviePlayer = self.view.bounds.width;
        let heightMoviePlayer = self.view.bounds.height;
        self.cameraButton.frame = CGRect(x: widthMoviePlayer-self.sizeCameraButton, y: heightMoviePlayer-self.sizeCameraButton, width: self.sizeCameraButton, height: self.sizeCameraButton)
        if(self.popover != nil){
            self.popover.sourceRect = self.cameraButton.frame
        }
    }
    
    //Obtiene la primera camara funcionando y la despliega
    func getFirstCameraAndSetup()
    {
        let query = PFQuery(className: TableNames.Camera.rawValue);
        query.whereKey(TableCameraColumnNames.Animal.rawValue, equalTo: PFObject(outDataWithClassName: TableGalleryColumnNames.Animal.rawValue, objectId: self.animalId))
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                if(objects!.isEmpty){
                    let query = PFQuery(className: TableNames.VideoCapsule_table.rawValue)
                    query.whereKey(TableVideoCapsuleNames.AnimalID.rawValue, equalTo: PFObject(outDataWithClassName: TableGalleryColumnNames.Animal.rawValue, objectId: self.animalId))
                    query.findObjectsInBackground(block: { (array, error) -> Void in
                        
                        guard error == nil, let videos = array, videos.count > 0 else{
                            self.performSegue(withIdentifier: "noCamerasSegue", sender: self)
                            return
                        }
                        let a:UInt32 = UInt32(videos.count)
                        let videoID = Int(arc4random_uniform(a))
                        let capsule = Capsule(object: videos[videoID], delegate: nil)
                        DispatchQueue.main.async{
                            self.performSegue(withIdentifier: "loadCapsule", sender: capsule)
                        }
                        return
                    })

                    return;
                }
                // Do something with the found objects
                if let objects = objects{
                    for object in objects{
                        let newCamera = Camera(object: object)
                        if(newCamera.funcionando! && newCamera.url != nil){//not necesary anymore
                            self.url = newCamera.url!;
                            self.camera = newCamera
                            self.setup()
                            return
                        }
                    }
                }
    
                self.performSegue(withIdentifier: "noCamerasSegue", sender: self)
                return;
            }
            else {
                print("Error: \(error!) \(error!.localizedDescription)")
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination
        if let vc = viewController as? NoCamerasViewController
        {
            vc.backImage = self.backgroundImageNoCameras
            vc.dismissProtocol = self
        }
        else if segue.identifier == "loadCapsule"{
            
            let vc = viewController as!  VideoCapsulasViewController
            vc.requireToolBar(true)
            vc.capsule = sender as! Capsule
            vc.user = user
        }
    }
    
    func setup(){
        let sizeScreen = UIScreen.main.bounds;
        let widthMoviePlayer = sizeScreen.width;
        let heightMoviePlayer = sizeScreen.height;
        let image = (UIImage(named: "camera")!).withRenderingMode(.alwaysTemplate)
        self.cameraButton  = UIButton(type: UIButtonType.custom)
        self.cameraButton.setImage(image, for: UIControlState())
        
        if user.hasLoadedPriority{
            self.cameraButton.imageView?.tintColor = user.type!.color
        }
        
        user.appendTypeLoadingObserver({
            [weak self]
            (_, type) -> (Bool) in
            
            guard let obj = self else{
                return false
            }
            
            if let type = type{
                obj.cameraButton.imageView?.tintColor = type.color
            }
            
            return true
            
        })
        
        
        self.cameraButton.frame = CGRect(x: widthMoviePlayer-self.sizeCameraButton, y: heightMoviePlayer-self.sizeCameraButton, width: self.sizeCameraButton, height: self.sizeCameraButton)
        self.cameraButton.addTarget(self, action: #selector(VideoViewController.cameraButtonClicked(_:)), for: UIControlEvents.touchUpInside)
        self.player = AVPlayer(url: url);
        self.view.addSubview(self.cameraButton);
        self.player?.play();
        self.camera?.startWatchingVideo()
        self.player?.isClosedCaptionDisplayEnabled = false;
        NotificationCenter.default.addObserver(self, selector: #selector(VideoViewController.doneButtonClick(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(VideoViewController.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        self.popover = nil
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        dissmising = true
        super.dismiss(animated: true, completion: {
            _ in
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        })
    }
    
    func cameraWillChange(_ newCamera: Camera) {
        self.camera?.stopWatchingVideo()
        self.camera = newCamera
        self.camera?.startWatchingVideo()
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.allButUpsideDown
    }
}

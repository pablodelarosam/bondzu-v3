//
//  AboutViewController.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 10/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//

import UIKit
import Parse

class AboutViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var backgroundImage : UIImageView!
    @IBOutlet weak var visibleImage : UIImageView!
    @IBOutlet weak var blurContainer: UIView!
    @IBOutlet weak var lateral : AboutLateralView!
    @IBOutlet weak var speciesLabel : UILabel!
    @IBOutlet weak var textView: UITextView!
    

    var image : UIImage?
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light)) as UIVisualEffectView

    @IBOutlet weak var adopt : CircledButton!
    @IBOutlet weak var goLive : CircledButton!
    
    var animalID = "oDUea7l41Y"
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = "About"
        let live = UIBarButtonItem(title: "Cams", style: .Plain, target: self, action: "showCams:")
        self.navigationController!.navigationBar.topItem!.rightBarButtonItem = live
        super.viewDidAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        heightConstraint.constant = UIScreen.mainScreen().bounds.height / 3
        widthConstraint.constant = UIScreen.mainScreen().bounds.width / 3
        visualEffectView.frame.size = CGSize( width: UIScreen.mainScreen().bounds.width ,height: heightConstraint.constant)
        Imagenes.redondeaVista(visibleImage, radio: visibleImage.frame.size.width/2)
        blurContainer.alpha = 1
    }
    
    override func viewDidLayoutSubviews() {
        Imagenes.redondeaVista(visibleImage, radio: visibleImage.bounds.size.height/2)
        blurContainer.alpha = 0.8
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        blurContainer.addSubview(visualEffectView)
        adopt.image = UIImage(named: "whitePaw")
        goLive.image = UIImage(named: "whiteCam")
        adopt.text = "Adopt"
        goLive.text = "Go Live"
        goLive.target = showCams
        let query = PFQuery(className: "AnimalV2")
        query.getObjectInBackgroundWithId(animalID){
            (animalObject: PFObject?, error: NSError?) -> Void in
            if error == nil{
                guard let animal = animalObject else{
                    return
                }
                
                dispatch_async(dispatch_get_main_queue()){
                    self.navigationItem.title = (animal["name"] as! String)
                    self.lateral.setAdopters((animal["adopters"] as! NSNumber).integerValue)
                    self.speciesLabel.text = (animal["species"] as! String)
                    
                    for (name , value) in animal["characteristics"] as! [String:String]{
                        self.appendAnimalAttributeWithName(name, value: value)
                    }
                    
                    self.appendHeadLine("About")
                    self.appendText(animal["about"] as! String)
                }
                
                (animal["profilePhoto"] as! PFFile).getDataInBackgroundWithBlock(){
                    data , error in
                    guard error == nil else{
                        print(error)
                        return
                    }
                    
                    guard let imageData = data else{
                        print("data is null\n")
                        return
                    }
                    
                    let image = UIImage(data: imageData)
                    self.visibleImage.hidden = false
                    self.image = image
                    
                    let sizedImage = imageWithImage(image!, scaledToSize: self.backgroundImage.frame.size)
                    
                    dispatch_async(dispatch_get_main_queue()){
                        self.backgroundImage.image = sizedImage
                        self.visibleImage.image = sizedImage
                    }
                }
                
                if let events = animal["events"] as? NSArray{
                    if events.count > 0{
                        let e  = events[0] as! PFObject
                        e.fetchInBackgroundWithBlock(){
                            object, error in
                            guard error == nil, let event = object else{
                                return
                            }
                            
                            //TODO buscar evento con foto si existe
                            
                            if let photo = event["event_photo"] as? PFFile{
                                photo.getDataInBackgroundWithBlock(){
                                    data , error in
                                    dispatch_async(dispatch_get_main_queue()){
                                        guard error == nil, let imageData = data else{
                                            self.lateral.setEventData( nil, title: event["title"] as! String)
                                            return
                                        }
                                        
                                        self.lateral.setEventData( UIImage(data: imageData), title: event["title"] as! String)
                                    }
                                }
                            }
                            else{
                                dispatch_async(dispatch_get_main_queue()){
                                    self.lateral.setEventData( nil, title: event["title"] as! String)
                                }
                            }
                        }
                    }
                }
                
                let keepersOptional = animal["keepers"] as? NSArray
                
                guard let keepers = keepersOptional else{
                    return
                }
                
                var count = 0
                for keeper in keepers{
                    (keeper as! PFObject).fetchIfNeededInBackgroundWithBlock({
                        object, error in
                        guard error == nil , let k = object else{
                            print("error al obtener a los cuidadores")
                            return
                        }
                        
                        let userObject = k["user"] as! PFObject
                        userObject.fetchIfNeededInBackgroundWithBlock(){
                            user, error in
                            guard error == nil , let selectedUser = user else{
                                print("error al obtener a los cuidadores")
                                return
                            }
                            
                            let cuidador = Usuario(name: selectedUser["name"] as! String , photo: selectedUser["photo"] as! String)
                            cuidador.loadImage()
                            cuidador.imageLoaderObserver = self.lateral.photoReady
                            
                            if(count == 0){
                                self.lateral.keeper1 = cuidador
                            }
                            else{
                                self.lateral.keeper2 = cuidador
                            }
                            
                            count++
                        }
                    })
                }
                
                print(animal)
            } else {
                print(error)
            }
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let liveStreamVC = segue.destinationViewController as! VideoViewController
        liveStreamVC.animalId = animalID
        
        
        //TESTING
        //liveStreamVC.animalId = "uoG4QimJN9"
    }
    
    func showCams(button: CircledButton)
    {
        self.performSegueWithIdentifier("liveStreamSegue", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func appendAnimalAttributeWithName(name : String, value: String){
        let nameDescriptor = [NSFontAttributeName : UIFont(descriptor: UIFontDescriptor(name: "Helvetica-Light", size: 10), size: 10)]
        let valueDescriptor = [NSFontAttributeName : UIFont(descriptor: UIFontDescriptor(name: "Helvetica-Light", size: 10), size: 10), NSForegroundColorAttributeName : UIColor.darkGrayColor()]
        textView.textStorage.appendAttributedString( NSAttributedString(string: "\(name): ", attributes: nameDescriptor))
        textView.textStorage.appendAttributedString( NSAttributedString(string: "\(value)\n", attributes: valueDescriptor))
    }
    
    func appendHeadLine(title : String){
        let headlineeDescriptor = [NSFontAttributeName : UIFont(descriptor: UIFontDescriptor(name: "Helvetica-Bold", size: 15), size: 15)]
        textView.textStorage.appendAttributedString( NSAttributedString(string: "\n\(title)\n", attributes: headlineeDescriptor))
    }
    
    func appendText(text : String){
        let textDescriptor = [NSFontAttributeName : UIFont(descriptor: UIFontDescriptor(name: "Helvetica", size: 12), size: 12)]
        textView.textStorage.appendAttributedString( NSAttributedString(string: "\(text)", attributes: textDescriptor))
    }
    
    override func viewWillDisappear(animated: Bool) {
        print("DESAPAREZCO")
    }
    
    deinit{
        print("\n\nADIOS MUNDO CRUEL\n\n")
    }
}


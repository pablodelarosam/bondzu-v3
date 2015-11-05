//
//  AboutViewController.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 10/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//  ARCHIVO LOCALIZADO

//Ab1234**
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
    
    var animalID = ""
    var animal : PFObject?
    
    var navBarTitle = NSLocalizedString("About", comment: "")
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = navBarTitle
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillLayoutSubviews() {
        heightConstraint.constant = UIScreen.mainScreen().bounds.height / 3
        widthConstraint.constant = UIScreen.mainScreen().bounds.width / 3
        visualEffectView.frame.size = CGSize( width: UIScreen.mainScreen().bounds.width ,height: heightConstraint.constant)
        blurContainer.alpha = 1
    }
    
    override func viewDidLayoutSubviews() {
        blurContainer.alpha = 0.8
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        blurContainer.addSubview(visualEffectView)
        adopt.image = UIImage(named: "whitePaw")
        goLive.image = UIImage(named: "whiteCam")
        adopt.text = NSLocalizedString("Adopt", comment: "")
        goLive.text = NSLocalizedString("Go Live", comment: "")
        goLive.target = showCams
    
        lateral.moreButton.addTarget(self, action: "segueToEvents", forControlEvents: UIControlEvents.TouchUpInside)
        
        adopt.target = {
            _ in
            self.adopt.userInteractionEnabled = false
            let user = PFUser.currentUser()!
            let relation = user.relationForKey(TableUserColumnNames.AdoptedAnimalsRelation.rawValue)
            let query = relation.query()
            query?.findObjectsInBackgroundWithBlock(){
                adopted , error in

                guard self.animal != nil else{
                    return
                }
                
                guard error == nil , let animals = adopted else{
                    self.adopt!.userInteractionEnabled = true
                    print("error al obtener información")
                    return
                }
                
                for animal in animals{
                    if (animal).objectId == self.animalID{
                        dispatch_async(dispatch_get_main_queue()){
                            let controller = UIAlertController(title: NSLocalizedString("Already adopted", comment: ""), message: NSLocalizedString("You cannot adopt the same animal twice", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                            controller.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler: {
                                _ in
                            }))
                            self.presentViewController(controller, animated: true, completion: nil)
                        }
                        return
                    }
                }
                
                let relation = user.relationForKey(TableUserColumnNames.AdoptedAnimalsRelation.rawValue)
                relation.addObject(self.animal!)
                PFUser.currentUser()!.saveInBackgroundWithBlock(){
                    a, b  in
                    dispatch_async(dispatch_get_main_queue()){
                        
                        let controller = UIAlertController(title: NSLocalizedString("Thank you!", comment: ""), message: NSLocalizedString("You have successfully adopted this animal. Make sure to take care of it and to visit it constantly on the cameras!.", comment: ""),     preferredStyle: UIAlertControllerStyle.Alert)
                        controller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Default, handler: {
                            _ in
                        }))
                        self.presentViewController(controller, animated: true, completion: nil)
                        
                        if let currentAnimal = self.animal{
                            currentAnimal.incrementKey(TableAnimalColumnNames.Adopters.rawValue, byAmount: 1)
                            currentAnimal.saveInBackgroundWithBlock({ b, e  in
                                if !b || e != nil{
                                    print("Error al actualizar el número de adopters");
                                }
                            })
                            
                            dispatch_async(dispatch_get_main_queue()){
                                if let i = self.lateral.getAdopters(){
                                    self.lateral.setAdopters(i + 1)
                                }
                            }
                        }
                    }
                }
                
                self.adopt.userInteractionEnabled = true
            }
            
            
            
        }
        
        let query = PFQuery(className: TableNames.Animal_table.rawValue)
        query.getObjectInBackgroundWithId(animalID){
            (animalObject: PFObject?, error: NSError?) -> Void in
            if error == nil{
                guard let animal = animalObject else{
                    return
                }
                self.animal = animal
                
                dispatch_async(dispatch_get_main_queue()){
                    self.navBarTitle = animal[TableAnimalColumnNames.Name.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! String
                    self.navigationController?.navigationBar.topItem?.title = (animal[TableAnimalColumnNames.Name.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! String)
                    self.lateral.setAdopters((animal[TableAnimalColumnNames.Adopters.rawValue] as! NSNumber).integerValue)
                    self.speciesLabel.text = (animal[TableAnimalColumnNames.Species.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! String)
                    
                    for (name , value) in animal[TableAnimalColumnNames.Characteristics.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! [String:String]{
                        self.appendAnimalAttributeWithName(name, value: value)
                    }
                    
                    self.appendHeadLine(NSLocalizedString("About", comment: ""))
                    self.appendText(animal[TableAnimalColumnNames.About.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! String)
                }
                
                (animal[TableAnimalColumnNames.Photo.rawValue] as! PFFile).getDataInBackgroundWithBlock(){
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
                
                
                let eventsQuery = PFQuery(className: TableNames.Events_table.rawValue)
                eventsQuery.whereKey(TableEventsColumnNames.Animal_ID.rawValue, equalTo: animal)
                eventsQuery.whereKey(TableEventsColumnNames.End_Day.rawValue, greaterThan: NSDate())
                eventsQuery.getFirstObjectInBackgroundWithBlock({
                    (event, error) -> Void in
                    
                    if error == nil && event != nil{
                        let photoFile = event![TableEventsColumnNames.Image_Name.rawValue] as! PFFile
                        photoFile.getDataInBackgroundWithBlock({
                            data, error in
                            let img = UIImage(data: data!)!
                            dispatch_async(dispatch_get_main_queue()){
                                self.lateral.setEventData(img, title: event![TableEventsColumnNames.Name.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! String)
                            }
                        })
                    }
                    
                })
                
                let keepersOptional = animal[TableAnimalColumnNames.Keepers.rawValue] as? NSArray
                
                guard let keepers = keepersOptional else{
                    print("El animal elegido no tiene keepers")
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
                        
                        let userObject = k[TableKeeperColumnNames.User.rawValue] as! PFObject
                        userObject.fetchIfNeededInBackgroundWithBlock(){
                            user, error in
                            guard error == nil , let selectedUser = user else{
                                print("error al obtener a los cuidadores")
                                return
                            }
                            
                            var cuidador : Usuario?
                            
                            if let pictureString = selectedUser[TableUserColumnNames.PhotoURL.rawValue] as? String{
                                cuidador = Usuario(name: selectedUser[TableUserColumnNames.Name.rawValue] as! String , photo: pictureString)
                            }
                            else if let pictureFile = selectedUser[TableUserColumnNames.PhotoFile.rawValue] as? PFFile{
                                cuidador = Usuario(name: selectedUser[TableUserColumnNames.Name.rawValue] as! String, photoFile: pictureFile)
                            }
                            
                            if cuidador != nil{
                                cuidador!.imageLoaderObserver = self.lateral.photoReady
            
                                if(count == 0){
                                    self.lateral.keeper1 = cuidador!
                                }
                                else{
                                    self.lateral.keeper2 = cuidador!
                                }
                                
                                count++
                            }
                        }
                    })
                }
            } else {
                print(error)
            }
        }
    }
    
    func takeScreenshot() -> UIImage
    {
        let layer = UIApplication.sharedApplication().keyWindow!.layer
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return screenshot;
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "liveStreamSegue"{
            let liveStreamVC = segue.destinationViewController as! VideoViewController
            liveStreamVC.animalId = animalID
            liveStreamVC.backgroundImageNoCameras = takeScreenshot()
        }
        else if segue.identifier == "events"{
            let eventsVC = segue.destinationViewController as! EventViewControllerTableViewController
            eventsVC.animal = self.animal!
        }
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
    
    func segueToEvents(){
        self.performSegueWithIdentifier("events", sender: nil)
    }
    
    @IBAction func unwind(segue : UIStoryboardSegue){}
}


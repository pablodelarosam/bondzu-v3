//
//  AboutViewController.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 10/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//  ARCHIVO LOCALIZADO

/*
    Archivo afectado issue #25
    Funciones viewDidLoad
*/

//TODO: Aqui hay un mega bloque de funciones que se llaman en background cuando ni siquiera era necesario.
import UIKit
import Parse

class AboutViewController: UIViewController, UITextViewDelegate, AnimalV2LoadingProtocol, EventLoadingDelegate {

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
    var animal : AnimalV2?
    
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
                relation.addObject(self.animal!.originalObject)
                PFUser.currentUser()!.saveInBackgroundWithBlock(){
                    a, b  in
                    dispatch_async(dispatch_get_main_queue()){
                        
                        let controller = UIAlertController(title: NSLocalizedString("Thank you!", comment: ""), message: NSLocalizedString("You have successfully adopted this animal. Make sure to take care of it and to visit it constantly on the cameras!.", comment: ""),     preferredStyle: UIAlertControllerStyle.Alert)
                        controller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Default, handler: {
                            _ in
                        }))
                        self.presentViewController(controller, animated: true, completion: nil)
                        
                        if let currentAnimal = self.animal?.originalObject{
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
            
            
            
        } //Clara afectación #25
        
        let query = PFQuery(className: TableNames.Animal_table.rawValue)
        query.getObjectInBackgroundWithId(animalID){
            (animalObject: PFObject?, error: NSError?) -> Void in
            if error == nil{
                guard let animal = animalObject else{
                    print("ERROR FATAL VIEWDIDLOAD ABOUTVIEWCONTROLLER")
                    return
                }
                
                self.animal = AnimalV2(object: animal, delegate: self)
                
                dispatch_async(dispatch_get_main_queue()){
                    self.navBarTitle = self.animal!.name
                    self.navigationController?.navigationBar.topItem?.title = self.animal!.name
                    self.lateral.setAdopters(self.animal!.adopters)
                    self.speciesLabel.text = self.animal!.specie
                    
                    for (name , value) in self.animal!.characteristics{
                        self.appendAnimalAttributeWithName(name, value: value)
                    }
                    self.appendHeadLine(NSLocalizedString("About", comment: ""))
                    self.appendText(self.animal!.about)
                }
                
                
                //FIXME: Afectacion #25
                let eventsQuery = PFQuery(className: TableNames.Events_table.rawValue)
                eventsQuery.whereKey(TableEventsColumnNames.Animal_ID.rawValue, equalTo: animal)
                eventsQuery.whereKey(TableEventsColumnNames.End_Day.rawValue, greaterThan: NSDate())
                eventsQuery.getFirstObjectInBackgroundWithBlock({
                    (eventObject, error) -> Void in
    
                    if error == nil && eventObject != nil{
                        _ = Event(object: eventObject!, delegate: self)
                    }
                    
                })
                
                guard self.animal?.keepers != nil  else{
                    print("El animal elegido no tiene keepers")
                    return
                }
                
                var count = 0
                for keeper in self.animal!.keepers!{
                    keeper.fetchIfNeededInBackgroundWithBlock({
                        object, error in
                        guard error == nil , let k = object else{
                            print("error al obtener a los cuidadores")
                            return
                        }
                        
                        Keeper.getKeeper(k, imageLoaderObserver: {
                            (user, bool) -> (Void) in
                            if user != nil{
                                self.lateral.photoDidLoad(user!, completed: bool)
                                if(count == 0){
                                    dispatch_async(dispatch_get_main_queue()){
                                        self.lateral.keeper1 = user
                                    }
                                }//Keeper 1 object
                                else{
                                    dispatch_async(dispatch_get_main_queue()){
                                        self.lateral.keeper2 = user
                                    }
                                }//Keeper 2 object
                                count++
                            } // Valid user
                        })//Retrive keeper
                    }) //Get keepers In background
                } //For keepers
            } // Get animal
            else {
                print(error)
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    func takeScreenshot() -> UIImage{
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
            eventsVC.animal = self.animal?.originalObject
        }
    }
    
    func showCams(button: CircledButton){
        self.performSegueWithIdentifier("liveStreamSegue", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func animalDidFailLoading( animal : AnimalV2 ) {
        print("No se pudo cargar imagen")
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func animalDidFinishLoading( animal : AnimalV2 ) {
        let image = self.animal!.image
        self.visibleImage.hidden = false
        self.image = image
        
        self.animal!.image = imageWithImage(self.animal!.image!, scaledToSize: self.backgroundImage.frame.size)
        
        dispatch_async(dispatch_get_main_queue()){
            self.backgroundImage.image = self.animal!.image
            self.visibleImage.image = self.animal!.image
        }

    }
    
    func eventDidFinishLoading(event: Event!) {
        dispatch_async(dispatch_get_main_queue()){
            self.lateral.setEventData(event.eventImage, title: event.eventName)
        }
    }
    
    func eventDidFailLoading(event: Event!) {}
}


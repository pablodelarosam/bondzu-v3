//
//  AboutViewController.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 10/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//  ARCHIVO LOCALIZADO

//TODO: Aqui hay un mega bloque de funciones que se llaman en background cuando ni siquiera era necesario.
import UIKit
import Parse

///This view controller is the responsable of showing the animal information and link it to the cameras and adoption buttons. It extends UIViewController and implements delegates for textView, animalv2 and events. In order to work, this controller needs a blocking helper and a user.
class AboutViewController: UIViewController, UITextViewDelegate, AnimalV2LoadingProtocol, EventLoadingDelegate{

    ///The currently logged in user
    var user : Usuario!
    
    ///The blured animal image
    @IBOutlet weak var backgroundImage : UIImageView!
    
    ///The circular portion of the image that is visible
    @IBOutlet weak var visibleImage : UIImageView!
    
    ///A view that will contain a blur effect
    @IBOutlet weak var blurContainer: UIView!
    
    ///The rigth lateral view that will be shown.
    @IBOutlet weak var lateral : AboutLateralView!
    
    ///The species label
    @IBOutlet weak var speciesLabel : UILabel!
    
    ///The textView that shows the animal information
    @IBOutlet weak var textView: UITextView!
    
    ///A passed instance of a blocking helper
    weak var blockingHelper : UserBlockingHelper? = nil

    ///The animal image that is going to be set for the image Views (The blurred and the not blurred one)
    var image : UIImage?
    
    ///A constraint that manages how much space does the rigth part takes
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    ///A constraint that manages how much space does the top image takes
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    ///The blur itself
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light)) as UIVisualEffectView

    ///A circular button that makes the user to adopt an animal
    @IBOutlet weak var adopt : CircledButton!
    
    ///A circular button that goes to the camera
    @IBOutlet weak var goLive : CircledButton!
    
    ///The parse object id to retrive
    var animalID = ""
    
    ///The animalV2 instance that the controller should show.
    var animal : AnimalV2?
    
    ///The localized navigation bar title
    var navBarTitle = NSLocalizedString("About", comment: "")
    
    
    ///The implementation of this method is to set the navigation bar title every time a tab bar appears
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = navBarTitle
    }
    
    ///The light bar should appear white
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    ///Update the constraints with the new device orientation / size. Also resets the blur container alpha so it dosen't get invalidated.
    override func viewWillLayoutSubviews() {
        heightConstraint.constant = UIScreen.mainScreen().bounds.height / 3
        widthConstraint.constant = UIScreen.mainScreen().bounds.width / 3
        visualEffectView.frame.size = CGSize( width: UIScreen.mainScreen().bounds.width ,height: heightConstraint.constant)
        blurContainer.alpha = 1
    }
    
    ///Resets the blur container alpha to 0.8 to get a better blur effect
    override func viewDidLayoutSubviews() {
        blurContainer.alpha = 0.8
    }
    
    
    ///Updates the background of images for the user can see their type while the images are not yet loaded
    func updateTabBarColor(){
        if user.hasLoadedPriority{
            backgroundImage.backgroundColor = user.type!.color
            visibleImage.backgroundColor = user.type!.color
        }
    }
    
    
    /**
     This function starts up blur container and prepare the circled buttons
     Also performs the query to get the animal and seeds the information to the view
     */
    override func viewDidLoad() {
    
        super.viewDidLoad()
        blurContainer.addSubview(visualEffectView)
        adopt.image = UIImage(named: "whitePaw")
        goLive.image = UIImage(named: "whiteCam")
        adopt.text = NSLocalizedString("Adopt", comment: "")
        goLive.text = NSLocalizedString("Go Live", comment: "")
        goLive.setTargetAction {
            [weak self]
            _ in
            self?.performSegueWithIdentifier("liveStreamSegue", sender: self)

        }

        lateral.moreButton.addTarget(self, action: "segueToEvents", forControlEvents: UIControlEvents.TouchUpInside)

        
//
//        lateral.moreButton.setTargetAction {
//            [weak self]
//            _ in
//            self?.performSegueWithIdentifier("events", sender: self)
//        }

        
    
    
        user.appendTypeLoadingObserver({
            [weak self]
            _ -> Bool in
            
            if let o = self{
                o.updateTabBarColor()
                return true
            }
            return false
        })
        
        updateTabBarColor()
        
        queryAnimal()
        
        adopt.setTargetAction {
            [weak self]
            _ in
            
            guard let s = self else{
                return
            }
            
            s.adopt.userInteractionEnabled = false
            dispatch_async(Constantes.get_bondzu_queue()){
                let result = Usuario.adoptAnimal(s.animalID)
                
                var title = ""
                var message = ""
                var actionTitle = ""
                
                s.adopt?.userInteractionEnabled = true
                
                dispatch_async(dispatch_get_main_queue()){
                    if result == UsuarioTransactionResult.Success{
                        
                        title = NSLocalizedString("Thank you!", comment: "")
                        //Modification, the message now confirms you which animal you just adopted
                        let message1 = NSLocalizedString("Thank you for adopting me. You have adopted", comment: "")
                        message = "\(message1): \(self!.animal!.name)"
                        actionTitle = NSLocalizedString("OK", comment: "")
                        
                        if let adopters = s.lateral.getAdopters(){
                            s.lateral.setAdopters(adopters + 1)
                        }
                    }
                    else if result == UsuarioTransactionResult.AlreadyAdopted{
                        
                        title = NSLocalizedString("Already adopted", comment: "")
                        //Visita nuestra tienda para conocer otras formas de apoyar a
                        let m1 = NSLocalizedString("You cannot adopt the same animal twice", comment: "")
                        message = "\(m1) \(self!.animal!.name)"
                        actionTitle = NSLocalizedString("Cancel", comment: "")
                        
                    }
                    else if result == UsuarioTransactionResult.ParseError{
                        
                        title = NSLocalizedString("Error", comment: "")
                        message = NSLocalizedString("Something went wrong, please try again later", comment: "")
                        actionTitle = NSLocalizedString("Cancel", comment: "")
                        
                    }
                    
                    let controller = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    controller.addAction(UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Cancel, handler: {
                        _ in
                    }))
                    s.presentViewController(controller, animated: true, completion: nil)
                }
                
            }
        }
        
        
    }
    
    func queryAnimal(){
    
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
                
                //DWH
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
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "liveStreamSegue"{
            let liveStreamVC = segue.destinationViewController as! VideoViewController
            liveStreamVC.animalId = animalID
            liveStreamVC.backgroundImageNoCameras = captureScreen()
            liveStreamVC.user = user
        }
        else if segue.identifier == "events"{
            let eventsVC = segue.destinationViewController as! EventViewControllerTableViewController
            eventsVC.animal = self.animal?.originalObject
        }
    }
    
    
    //DWH
    func segueToEvents(){
        self.performSegueWithIdentifier("events", sender: nil)
    }
    
    /**
     This function is used to append items to the animal characteristics.
     The parameters are the name that will appear as a black label and the value that will appear in gray
        
          example: name = weigth, value = 62 pounds
     
     - parameter name: The description or key of the value
     - parameter value: The value that correspond to the key
     
     
     */
    private func appendAnimalAttributeWithName(name : String, value: String){
        let nameDescriptor = [NSFontAttributeName : UIFont(descriptor: UIFontDescriptor(name: "Helvetica", size: 12), size: 12)]
        let valueDescriptor = [NSFontAttributeName : UIFont(descriptor: UIFontDescriptor(name: "Helvetica", size: 12), size: 12)/*, NSForegroundColorAttributeName : UIColor.darkGrayColor()*/]
        textView.textStorage.appendAttributedString( NSAttributedString(string: "\(name): ", attributes: nameDescriptor))
        textView.textStorage.appendAttributedString( NSAttributedString(string: "\(value)\n", attributes: valueDescriptor))
    }
    
    /**
     This method is provided to append a header to the animal information
     The text will be presented in bold
     
     - parameter title: The title that is going to be appended
     */
    private func appendHeadLine(title : String){
        let headlineeDescriptor = [NSFontAttributeName : UIFont(descriptor: UIFontDescriptor(name: "Helvetica-Bold", size: 15), size: 15)]
        textView.textStorage.appendAttributedString( NSAttributedString(string: "\n\(title)\n", attributes: headlineeDescriptor))
    }
    
    /**
     This method is provided to append plain text to the animal information
     
     - parameter text: The text that is going to be appended
     */
    private func appendText(text : String){
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Justified
        
        let textDescriptor = [
            NSParagraphStyleAttributeName: paragraphStyle,
            NSBaselineOffsetAttributeName: NSNumber(float: 0),
            NSFontAttributeName : UIFont(descriptor: UIFontDescriptor(name: "Helvetica", size: 12), size: 12)]
       
        textView.textStorage.appendAttributedString( NSAttributedString(string: "\(text)", attributes: textDescriptor))
    }
    
   
    
    
    
    //MARK: AnimalV2 Loading protocol implementation
    
    ///Pops the controller if the animal couldn't be loaded
    func animalDidFailLoading( animal : AnimalV2 ) {
        print("No se pudo cargar imagen")
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    ///Configures the animal images once they are loaded
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
    
    ///Tells the user that something went wrong and pops the view controller
    func animalDidFailedLoadingPermissionType(animal: AnimalV2) {
        let ac = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Something went wrong, please try again later", comment: ""), preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: {
            _ -> Void in
            self.navigationController?.popViewControllerAnimated(true)
        }))
    }
    
    ///Tells the blocking helper that the load of type is done
    func animalDidFinishLoadingPermissionType(animal: AnimalV2) {
        self.blockingHelper?.setRequiredPriority(animal.requiredPermission!.priority)
    }
    
    
    //Event protocol
    func eventDidFinishLoading(event: Event!) {
        dispatch_async(dispatch_get_main_queue()){
            self.lateral.setEventData(event.eventImage, title: event.eventName)
        }
    }
    
    func eventDidFailLoading(event: Event!) {}


}


//
//  CatalogViewController.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 12/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//  Archivo Localizado

//TODO posible bug here. Searching may do a circle reference here.

/*
    Affected issue #25
    getAnimals
*/

import UIKit
import Parse

class CatalogViewController: UIViewController, UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, CapsuleLoadingDelegate{

    //NOTE: To avoid possible bugs the search bar appears in the place of the segment control. Therefore is impossible to change the view while searching.
    
    //MARK: Constants
    
    ///Number of items per row. Possibly there will be a modification that takes landscape mode in mind or even different devices so this can become a computed variable.
    private var NUMBER_ITEMS_ROW: CGFloat{

        return 2
        
        /*let orientation = UIDevice.currentDevice().orientation
        if orientation == .Portrait || orientation == .PortraitUpsideDown || orientation == .FaceUp || orientation == .FaceDown{ return 2 }
        return 3*/
        
    }
    
    
    ///The image that appears when imageWithImage haven't finished processing
    private let initialThumbnail = UIImage()
    
    
    //MARK: Variables
    
    ///The animals model
    var animalsToShow = [AnimalV2]()
    
    ///This is a helper variable that changes the search icon with the done item when neccesary. The done item is created in runtime wile search one is stored here. This reference is necesary as the other one is weak and if its removed from the view it will go to null.
    private var barButtonItem : UIBarButtonItem?
    
    //?? TODO: Descubrir que hace esto
    private var navHairLine:UIImageView? = UIImageView()

    ///The filtered animals model
    var searchedAnimals = [AnimalV2]()
    
    ///The video capsules filtered model
    var searchedVideoCapsules = [Capsule]()
    
    ///A variable that tells if the selected item should be considered from the normal or the filtered array.
    private var searching = false
    
    
    ///The numbers of animals that havent loaded yet. When they're fully loaded the view changes showing the animals. Doing the loading in this manner ensures that the animals are shown in alphabetical order.
    var toLoadAnimals = 0
    
    ///The numbers of videos that havent loaded yet. When they're fully loaded the view changes showing the animals. Doing the loading in this manner ensures that the animals are shown in alphabetical order.
    var toLoadVideos = 0
    
    ///The video capsules model
    var videoCapsules = [Capsule]()
    
    //MARK: Background variables
    @IBOutlet weak var blurView: UIView!
    var backgroundImages = [UIImage]();
    @IBOutlet weak var backgroundImage: UIImageView!
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light)) as UIVisualEffectView
    let animationDuration: NSTimeInterval = 0.9
    let switchingInterval: NSTimeInterval = 5
    
    ///Weak bar of the searching element
    @IBOutlet weak var searchBarButtonItem: UIBarButtonItem!

    //MARK: View Outlets

    ///Loading indicator while the animals are loading
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    ///The view that displays the items in a collection view. This is both, the data sorce and the controller.
    @IBOutlet weak var collectionView: UICollectionView!
    
    ///Contant that is ment for future use with ads
    @IBOutlet weak var heightBanner: NSLayoutConstraint!
    
    ///The animals and videos searchbar
    @IBOutlet weak var searchBar: UISearchBar!
    
    ///The Animals/Video trigger
    @IBOutlet weak var segementedControl: UISegmentedControl!
    
    ///Place where the segmented control appears
    @IBOutlet weak var toolbar: UIToolbar!
    
    
    
    
    //MARK:Collection view delegate & data source
  
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if segementedControl.selectedSegmentIndex == 0{
            if toLoadAnimals == 0{
                if !activityIndicator.hidden{
                    self.activityIndicator.stopAnimating()
                }
                return searching ? self.searchedAnimals.count : self.animalsToShow.count
            }
            else{
                if activityIndicator.hidden{
                    self.activityIndicator.hidden = false
                    self.activityIndicator.startAnimating()
                }
                return 0;
            }
            
        }
        else{
            if toLoadVideos == 0{
                if !activityIndicator.hidden{
                    self.activityIndicator.stopAnimating()
                }
                return searching ? self.searchedVideoCapsules.count : self.videoCapsules.count
            }
            else{
                if activityIndicator.hidden{
                    self.activityIndicator.hidden = false
                    self.activityIndicator.startAnimating()
                }
                return 0
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("animalCell", forIndexPath: indexPath) as! AnimalCollectionViewCell
        cell.layer.shouldRasterize = true;
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale;
        cell.imageView.image = initialThumbnail
        
        cell.tab = segementedControl.selectedSegmentIndex
        cell.row = indexPath.row

        if segementedControl.selectedSegmentIndex == 0{
            let animal = searching ? self.searchedAnimals[indexPath.row] : self.animalsToShow[indexPath.row]
            cell.nameLabel.text = animal.name;
            cell.speciesLabel.text = animal.specie;
            let width = UIScreen.mainScreen().bounds.width
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let photoFinal = imageWithImage(animal.image, scaledToSize: CGSize(width: width / self.NUMBER_ITEMS_ROW, height:width / self.NUMBER_ITEMS_ROW))
                dispatch_async(dispatch_get_main_queue()) {
                    if cell.tab == self.segementedControl.selectedSegmentIndex && cell.row == indexPath.row{
                        cell.imageView.image = photoFinal
                    }
                }            
            }

        }
        else{
            let capsule = searching ? self.searchedVideoCapsules[indexPath.row] : self.videoCapsules[indexPath.row]
            cell.nameLabel.text = capsule.title[0]
            cell.speciesLabel.text = capsule.animalName;
            let width = UIScreen.mainScreen().bounds.width
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let photoFinal = imageWithImage(capsule.image, scaledToSize: CGSize(width:width / self.NUMBER_ITEMS_ROW, height:width / self.NUMBER_ITEMS_ROW))
                dispatch_async(dispatch_get_main_queue()) {
                    if cell.tab == self.segementedControl.selectedSegmentIndex && cell.row == indexPath.row{
                        cell.imageView.image = photoFinal
                    }
                }
            }
            
        }
        Imagenes.redondeaVista(cell.imageView, radio: cell.imageView.frame.size.width / 2);
        cell.imageView.layer.borderColor = UIColor.whiteColor().CGColor;
        cell.imageView.layer.borderWidth = 5;
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        if segementedControl.selectedSegmentIndex == 0{
            performSegueWithIdentifier("catalogSegue", sender: searching ? self.searchedAnimals[indexPath.row] : self.animalsToShow[indexPath.row])
            searching = false
            searchBar.resignFirstResponder()
        }
        else{
            performSegueWithIdentifier("capsule", sender: searching ? self.searchedVideoCapsules[indexPath.row] : self.videoCapsules[indexPath.row])
            searching = false
            searchBar.resignFirstResponder()
        }
    }
    
    //MARK: Video Capsule Delegate
    
    func capsuleDidFinishLoading(capsule: Capsule) {
        dispatch_async(dispatch_get_main_queue()){
            self.toLoadVideos--
            if self.segementedControl.selectedSegmentIndex == 1{
                self.collectionView.reloadData()
            }
        }
    }
    
    func capsuleDidFailLoading(capsule: Capsule) {
        dispatch_async(dispatch_get_main_queue()){
            let index = self.videoCapsules.indexOf(capsule)
            self.videoCapsules.removeAtIndex(index!)
            self.toLoadVideos--
        }
    }

    
    //MARK: Methods
    
    func animateBackgroundImageView(){
        CATransaction.begin()
        
        CATransaction.setAnimationDuration(animationDuration)
        CATransaction.setCompletionBlock {
            let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(self.switchingInterval * NSTimeInterval(NSEC_PER_SEC)))
            dispatch_after(delay, dispatch_get_main_queue()) {
                self.animateBackgroundImageView()
            }
        }
        let transition = CATransition()
        transition.type = kCATransitionFade
        self.backgroundImage.layer.addAnimation(transition, forKey: kCATransition)
        self.backgroundImage.image = self.backgroundImages[random() % self.backgroundImages.count]
        
        CATransaction.commit()
    }
    
    ///Performs the animal and video query. Note: The animalV2 filling should be migrated to the model
    func getAnimals(){
        let query = PFQuery(className:TableNames.Animal_table.rawValue)
        query.whereKeyExists(TableAnimalColumnNames.ID.rawValue);
        query.orderByAscending(TableAnimalColumnNames.Name.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: ""));
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                // The find succeeded.
                if let objects = objects{
                    self.toLoadAnimals = objects.count
                    var i = 0 as Int;
                    for object in objects {
                        let image = object.objectForKey(TableAnimalColumnNames.Photo.rawValue) as? PFFile;
                        if image != nil{
                            
                            let animal = AnimalV2();
                            animal.name = object.objectForKey(TableAnimalColumnNames.Name.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")) as! String;
                            animal.objectId = object.objectId!;
                            animal.specie = object.objectForKey(TableAnimalColumnNames.Species.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")) as! String;
                            self.animalsToShow.append(animal);
                            image?.getDataInBackgroundWithBlock{
                                (imageData: NSData?, error: NSError?) -> Void in
                                if error == nil{
                                    animal.image = UIImage(data: imageData!)!;
                                    dispatch_async(dispatch_get_main_queue()){
                                        self.toLoadAnimals--
                                        if self.segementedControl.selectedSegmentIndex == 0{
                                            self.collectionView.reloadData()
                                        }
                                    }
                                }
                                else{
                                    dispatch_async(dispatch_get_main_queue()){
                                        let index = self.animalsToShow.indexOf(animal)
                                        self.animalsToShow.removeAtIndex(index!)
                                         self.toLoadAnimals--
                                    }
                                }
                            }
                            i++;
                        }
                    }
                    dispatch_async(dispatch_get_main_queue()){
                        if self.segementedControl.selectedSegmentIndex == 0{
                            self.collectionView.reloadData()
                        }
                    }
                }
                
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }

        
        let videoQuery = PFQuery(className: TableNames.VideoCapsule_table.rawValue)
        videoQuery.orderByDescending(TableVideoCapsuleNames.Date.rawValue)
        videoQuery.findObjectsInBackgroundWithBlock {
            (array, error) -> Void in
            if error == nil, let capsulesArray = array{
                self.toLoadVideos = capsulesArray.count
                
                for object in capsulesArray{
                    let c = Capsule(object: object, delegate: self)
                    self.videoCapsules.append(c)
                }
                
                if self.segementedControl.selectedSegmentIndex == 1{
                    dispatch_async(dispatch_get_main_queue()){
                        self.collectionView.reloadData()
                    }
                }
            }
        }
        
    }
    
    ///Dissmises the keyboard
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        guard searchBar.text != nil else{ return }
        
        if searchBar.text?.characters.count == 0{
            searching = false
            return
        }
        
        searching = true
        searchBar.resignFirstResponder()
    }
    
    ///Function that is called when the search bar text changes. It determines if the user is searching and returns the result data.
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard searchBar.text != nil && searchBar.text?.characters.count != 0 else{
            searching = false
            collectionView.reloadData()
            return
        }
        
        searching = true
        
        if segementedControl.selectedSegmentIndex == 0{
            searchedAnimals = animalsToShow.filter({ (element) -> Bool in
                let name = element.name.lowercaseString.rangeOfString(searchBar.text!.lowercaseString)
                let species = element.specie.lowercaseString.rangeOfString(searchBar.text!.lowercaseString)
                
                if name != nil || species != nil{
                    return true
                }
                return false
            })
        }
        else{
            searchedVideoCapsules = videoCapsules.filter({ (element) -> Bool in
                let title = element.title[0].lowercaseString.rangeOfString(searchBar.text!.lowercaseString)
                let species = element.videoDescription[0].lowercaseString.rangeOfString(searchBar.text!.lowercaseString)
                let animal = element.animalName.lowercaseString.rangeOfString(searchBar.text!.lowercaseString)
                if title != nil || species != nil  || animal != nil{
                    return true
                }
                return false
            })
        }
        
        collectionView.reloadData()
    
    }
    
    ///Called when the search bar has to be either shown or dissmised
    @IBAction func searchButtonPressed(sender: AnyObject) {
        if !searchBar.hidden{
            searching = false
            searchBar.resignFirstResponder()
            collectionView.reloadData()
            searchBar.hidden = true
            navigationItem.rightBarButtonItem?.target = nil
            navigationItem.rightBarButtonItem?.action = nil
            if let bi = barButtonItem{
                self.navigationItem.rightBarButtonItem = bi
                barButtonItem = nil
            }
        }
        else{
            searchBar.hidden = false
            searchBar.becomeFirstResponder()
            barButtonItem = self.navigationItem.rightBarButtonItem
            self.searchBar(searchBar, textDidChange: searchBar.text != nil ? searchBar.text! : "")
            let bbi = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "searchButtonPressed:");
            navigationItem.rightBarButtonItem = bbi;
        }
    }

    ///This method is called when the user toggled between animals and video
    @IBAction func valueChanged(control : UISegmentedControl){
        collectionView.reloadData()
    }
    
    
    //MARK: View notifications
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("Home", comment: "")
    }
    
    override func viewDidDisappear(animated: Bool) {
        Utiles.moveHairLine(false, navHairLine: self.navHairLine, toolbar: self.toolbar)
        if !searchBar.hidden{
            searchButtonPressed(self)
        }
    }
    
    override func viewDidLayoutSubviews() {
        visualEffectView.frame.size = CGSize(width: self.collectionView.frame.width , height: self.collectionView.frame.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.heightBanner.constant = 0;
        self.navigationController?.navigationBar.barStyle = .Black
        self.navigationController?.navigationBar.barTintColor = Constantes.COLOR_NARANJA_NAVBAR
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        
        let cellWidth = ( min(UIScreen.mainScreen().bounds.width , UIScreen.mainScreen().bounds.height) - 15 * NUMBER_ITEMS_ROW) / NUMBER_ITEMS_ROW
        let cellLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        cellLayout.itemSize = CGSize(width: cellWidth, height: cellWidth + 20)
        cellLayout.minimumInteritemSpacing = 5
        
        self.collectionView.backgroundView?.alpha = 0;
        self.blurView.addSubview(visualEffectView)
        self.blurView.alpha = 0.92;
        self.backgroundImages.append(UIImage(named: "tigre")!)
        self.backgroundImages.append(UIImage(named: "dog")!)
        self.backgroundImages.append(UIImage(named: "leopard")!)
        self.backgroundImages.append(UIImage(named: "titi")!)
        self.backgroundImage.image = self.backgroundImages[random() % self.backgroundImages.count]
        animateBackgroundImageView()
        self.navHairLine = Utiles.getHairLine(self.navigationController!.navigationBar)
        self.toolbar.barStyle = .Black
        self.toolbar.barTintColor = Constantes.COLOR_NARANJA_NAVBAR
        self.segementedControl.tintColor = UIColor.whiteColor()
        getAnimals();
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.hidesBackButton = true;
        Utiles.moveHairLine(true, navHairLine: self.navHairLine, toolbar: self.toolbar)
    }
    
    //MARK: Other controller stuff
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "catalogSegue"{
            let nextVC = segue.destinationViewController as! TabsViewController
            nextVC.animal = sender as! AnimalV2
            
        }
        else if segue.identifier == "capsule"{
            let nextVC = segue.destinationViewController as! VideoCapsulasViewController
            nextVC.capsule = sender as! Capsule
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        let cellWidth = ( min(UIScreen.mainScreen().bounds.height, UIScreen.mainScreen().bounds.width) - 15 * NUMBER_ITEMS_ROW) / NUMBER_ITEMS_ROW
        let cellLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        cellLayout.itemSize = CGSize(width: cellWidth, height: cellWidth + 20)
        cellLayout.minimumInteritemSpacing = 5
    }

   
}

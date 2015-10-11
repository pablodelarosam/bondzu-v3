//
//  CatalogViewController.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 12/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//  Archivo Localizado

import UIKit
import Parse

class CatalogViewController: UIViewController, UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, CapsuleLoadingDelegate{

    var navHairLine:UIImageView? = UIImageView()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segementedControl: UISegmentedControl!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var heightBanner: NSLayoutConstraint!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var barButtonItem : UIBarButtonItem?
    
    let NUMBER_ITEMS_ROW: CGFloat = 3;
    
    var searching = false
    
    var searchedAnimals = [AnimalV2]()
    var animalsToShow = [AnimalV2]()
    var selectedAnimal: AnimalV2?;
    
    var searchedVideoCapsules = [Capsule]()
    var videoCapsules = [Capsule]()
    var selectedCapsue: Capsule?;

    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    @IBOutlet weak var blurView: UIView!
    var backgroundImages = [UIImage]();
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var searchBarButtonItem: UIBarButtonItem!

    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light)) as UIVisualEffectView
    let animationDuration: NSTimeInterval = 0.9
    let switchingInterval: NSTimeInterval = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.heightBanner.constant = 0;
        self.navigationController?.navigationBar.barStyle = .Black
        self.navigationController?.navigationBar.barTintColor = Constantes.COLOR_NARANJA_NAVBAR
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        self.collectionView.backgroundView?.alpha = 0;
        screenSize = UIScreen.mainScreen().bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
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
        self.activityIndicator.startAnimating()
        getAnimals();
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.hidesBackButton = true;
        Utiles.moveHairLine(true, navHairLine: self.navHairLine, toolbar: self.toolbar)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("Home", comment: "")
    }
    
    override func viewDidDisappear(animated: Bool) {
        Utiles.moveHairLine(false, navHairLine: self.navHairLine, toolbar: self.toolbar)
    }

    override func viewDidLayoutSubviews() {
        visualEffectView.frame.size = CGSize(width: self.collectionView.frame.width , height: self.collectionView.frame.height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if segementedControl.selectedSegmentIndex == 0{
            return searching ? self.searchedAnimals.count : self.animalsToShow.count
        }
        else{
            return searching ? self.searchedVideoCapsules.count : self.videoCapsules.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("animalCell", forIndexPath: indexPath) as! AnimalCollectionViewCell
        cell.layer.shouldRasterize = true;
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale;
        
        if segementedControl.selectedSegmentIndex == 0{
            let animal = searching ? self.searchedAnimals[indexPath.row] : self.animalsToShow[indexPath.row]
            cell.nameLabel.text = animal.name;
            cell.speciesLabel.text = animal.specie;
            let photoFinal = imageWithImage(animal.image, scaledToSize: CGSize(width:self.screenWidth / NUMBER_ITEMS_ROW, height:self.screenWidth / NUMBER_ITEMS_ROW))
            cell.imageView.image = photoFinal

            /*var initialThumbnail = UIImage(named: "question")
            cell.imageView.image = initialThumbnail*/
            /*let priority = DISPATCH_QUEUE_PRIORITY_BACKGROUND
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                // do some task
                let photoFinal = imageWithImage(animal.image, scaledToSize: CGSize(width:self.screenWidth / self.NUMBER_ITEMS_ROW, height:self.screenWidth / self.NUMBER_ITEMS_ROW))
                dispatch_async(dispatch_get_main_queue()) {
                cell.imageView.image = photoFinal
                }            
            }*/

        }
        else{
            let capsule = searching ? self.searchedVideoCapsules[indexPath.row] : self.videoCapsules[indexPath.row]
            cell.nameLabel.text = capsule.title[0]
            cell.speciesLabel.text = capsule.animalName;
            let photoFinal = imageWithImage(capsule.image, scaledToSize: CGSize(width:self.screenWidth / NUMBER_ITEMS_ROW, height:self.screenWidth / NUMBER_ITEMS_ROW))
            cell.imageView.image = photoFinal
        }
        Imagenes.redondeaVista(cell.imageView, radio: cell.imageView.frame.size.width / 2);
        cell.imageView.layer.borderColor = UIColor.whiteColor().CGColor;
        cell.imageView.layer.borderWidth = 5;
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        if segementedControl.selectedSegmentIndex == 0{
            self.selectedAnimal = searching ? self.searchedAnimals[indexPath.row] : self.animalsToShow[indexPath.row];
            performSegueWithIdentifier("catalogSegue", sender: self)
        }
        else{
            self.selectedCapsue = searching ? self.searchedVideoCapsules[indexPath.row] : self.videoCapsules[indexPath.row];
            performSegueWithIdentifier("capsule", sender: self)
        }
        
        

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "catalogSegue"{
            let nextVC = segue.destinationViewController as! TabsViewController
            nextVC.animal = self.selectedAnimal
            
        }
        else if segue.identifier == "capsule"{
            let nextVC = segue.destinationViewController as! VideoCapsulasViewController
            nextVC.capsule = selectedCapsue
        }
    }
    
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
    
    func getAnimals(){
        let query = PFQuery(className:TableNames.Animal_table.rawValue)
        query.whereKeyExists(TableAnimalColumnNames.ID.rawValue);
        query.orderByAscending(TableAnimalColumnNames.Name.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: ""));
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) animals.")
                if let objects = objects as? [PFObject] {
                    var i = 0 as Int;
                    for object in objects {
                        i++;
                        
                        let image = object.objectForKey(TableAnimalColumnNames.Photo.rawValue) as? PFFile;
                        if image != nil{
                            image?.getDataInBackgroundWithBlock
                                {
                                    (imageData: NSData?, error: NSError?) -> Void in
                                    let animal = AnimalV2();
                                    if error == nil
                                    {
                                        animal.image = UIImage(data: imageData!);
                                    }
                                    animal.name = object.objectForKey(TableAnimalColumnNames.Name.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")) as! String;
                                    animal.objectId = object.objectId!;
                                    animal.specie = object.objectForKey(TableAnimalColumnNames.Species.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")) as! String;
                                    self.animalsToShow.append(animal);
                                    if self.segementedControl.selectedSegmentIndex == 0{
                                        self.collectionView.reloadData();
                                    }
                            }
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
                for object in capsulesArray as! [PFObject]{
                    _ = Capsule(object: object, delegate: self)
                }
            }
        }
        
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        guard searchBar.text != nil else{ return }
        
        if searchBar.text?.characters.count == 0{
            searching = false
            return
        }
        
        searching = true
        searchBar.resignFirstResponder()
        searchedAnimals = animalsToShow.filter({ (element) -> Bool in
            let name = element.name.lowercaseString.rangeOfString(searchBar.text!.lowercaseString)
            let species = element.specie.lowercaseString.rangeOfString(searchBar.text!.lowercaseString)
            
            if name != nil || species != nil{
                return true
            }
            return false
        })
        collectionView.reloadData()
    }
    
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
            let bbi = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "searchButtonPressed:");
            navigationItem.rightBarButtonItem = bbi;
        }
    }
    
    @IBAction func valueChanged(control : UISegmentedControl){
        collectionView.reloadData()
    }
    
    func capsuleDidFinishLoading(capsule: Capsule) {
        videoCapsules.append(capsule)
        if segementedControl.selectedSegmentIndex == 1{
            collectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: videoCapsules.count - 1, inSection: 0)])
        }
    }
    
    func capsuleDidFailLoading(capsule: Capsule) {}
}
